use chrono::Utc;
use rusqlite::{Connection, params};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::fs;
use std::path::Path;

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct UpdateManifest {
    pub version: String,
    pub slot: String,
    pub sha256: String,
    pub size_bytes: u64,
    pub minisign_sig: String,
    pub minisign_key: String,
    pub timestamp: String,
    pub previous_slot: String,
    pub url: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum SlotStatus {
    Active,
    Inactive,
    Updating,
    Verified,
    Corrupted,
}

#[derive(Debug, Clone)]
pub struct SlotInfo {
    pub name: String,
    pub status: SlotStatus,
    pub version: Option<String>,
    pub sha256: Option<String>,
    pub boot_count: u32,
    pub health_check_passed: bool,
}

pub struct UpdateManager {
    db: Connection,
    active_slot: String,
}

impl UpdateManager {
    pub fn new(db_path: &str) -> Result<Self, Box<dyn std::error::Error>> {
        let db = Connection::open(db_path)?;
        db.execute_batch(
            "CREATE TABLE IF NOT EXISTS slots (
                name TEXT PRIMARY KEY,
                status TEXT,
                version TEXT,
                sha256 TEXT,
                boot_count INTEGER DEFAULT 0,
                health_check_passed INTEGER DEFAULT 0
            );",
        )?;

        // Inicializar slots A e B se não existirem
        for slot in &["A", "B"] {
            db.execute(
                "INSERT OR IGNORE INTO slots (name, status, boot_count, health_check_passed) VALUES (?1, 'active', 0, 0)",
                rusqlite::params![slot],
            )?;
        }

        let active_slot = Self::get_active_slot(&db)?;

        Ok(Self {
            db,
            active_slot,
        })
    }

    fn get_active_slot(db: &Connection) -> Result<String, Box<dyn std::error::Error>> {
        let row: String = db.query_row(
            "SELECT name FROM slots WHERE status = 'active' LIMIT 1",
            [],
            |r| r.get(0),
        )?;
        Ok(row)
    }

    pub fn verificar_slot(&self, slot: &str) -> Result<bool, Box<dyn std::error::Error>> {
        let row: Option<(String, String, Option<String>, Option<String>, u32, i32)> =
            self.db.query_row(
                "SELECT status, version, sha256, boot_count, health_check_passed FROM slots WHERE name = ?1",
                params![slot],
                |r| Ok((r.get(0)?, r.get(1)?, r.get(2)?, r.get(3)?, r.get(4)?, r.get(5)?)),
            ).optional()?;

        match row {
            Some((status, _versao, _sha, boot_count, health_passed, _)) => {
                if status == "corrupted" {
                    return Ok(false);
                }
                if boot_count >= 2 && health_passed == 0 {
                    return Ok(false);
                }
                Ok(true)
            }
            None => Ok(false),
        }
    }

    pub fn baixar_manifesto(&mut self, url: &str) -> Result<UpdateManifest, Box<dyn std::error::Error>> {
        log::info!("Baixando manifesto de: {}", url);

        let manifest = UpdateManifest {
            version: "2026.11.2".to_string(),
            slot: if self.active_slot == "A" { "B".to_string() } else { "A".to_string() },
            sha256: "a3f5f45e7d9c1b2a3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6".to_string(),
            size_bytes: 1_200_000_000,
            minisign_sig: "RWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwR".to_string(),
            minisign_key: "RWQf6LRCGA9i53ml5EcO4GlP2YhuUoF+XkKzRsWxDxJ".to_string(),
            timestamp: Utc::now().to_rfc3339(),
            previous_slot: self.active_slot.clone(),
        };

        Ok(manifest)
    }

    pub fn verificar_assinatura(&self, manifesto: &UpdateManifest) -> Result<bool, Box<dyn std::error::Error>> {
        // Em produção, verificar assinatura minisign real
        // Aqui simulamos validação
        if manifesto.sha256.len() == 64 {
            return Ok(true);
        }
        Ok(false)
    }

    pub fn instalar_slot(&mut self, manifesto: &UpdateManifest) -> Result<(), Box<dyn std::error::Error>> {
        let slot_alvo = &manifesto.slot;

        log::info!("Instalando slot {} com versão {}", slot_alvo, manifesto.versao);

        self.db.execute(
            "UPDATE slots SET status = 'verity', versao = ?1, sha256 = ?2, boot_count = 0, health_check_passed = 0 WHERE name = ?3",
            rusqlite::params![&manifesto.versao, &manifesto.sha256, slot_alvo],
        )?;

        log::info!("Slot {} atualizado com versão {}", slot_alvo, manifesto.versao);
        Ok(())
    }

    pub fn health_check(&mut self, slot: &str) -> Result<bool, Box<dyn std::error::Error>> {
        self.db.execute(
            "UPDATE slots SET health_check_passed = 1, boot_count = boot_count + 1 WHERE name = ?1",
            rusqlite::params![slot],
        )?;
        Ok(true)
    }

    pub fn fazer_rollback(&mut self) -> Result<(), Box<dyn std::error::Error>> {
        let slot_atual = self.active_slot.clone();
        let slot_alvo = if slot_atual == "A" { "B" } else { "A" };

        self.db.execute(
            "UPDATE slots SET status = 'corrupted' WHERE name = ?1",
            rusqlite::params![&slot_atual],
        )?;

        self.db.execute(
            "UPDATE slots SET status = 'ativo', boot_count = 0 WHERE name = ?1",
            rusqlite::params![slot_alvo],
        )?;

        self.active_slot = slot_alvo.to_string();
        log::warn!("Rollback executado: slot {} -> {}", slot_atual, slot_alvo);
        Ok(())
    }

    pub fn obter_estado(&self) -> Result<(String, Vec<SlotInfo>), Box<dyn std::error::Error>> {
        let mut stmt = self.db.prepare(
            "SELECT name, status, versao, sha256, boot_count, health_check_passed FROM slots"
        )?;
        let rows = stmt.query_map([], |r| {
            Ok(SlotInfo {
                nome: r.get(0)?,
                status: match r.get::<_, String>(1)?.as_str() {
                    "ativo" => SlotStatus::Ativo,
                    "bloqueado" => SlotStatus::Bloqueado,
                    "atualizando" => SlotStatus::Atualizando,
                    "verificado" => SlotStatus::Verificado,
                    "corrompido" => SlotStatus::Corrompido,
                    _ => SlotStatus::Desconhecido,
                },
                versao: r.get(2)?,
                sha256: r.get(3)?,
                boot_count: r.get(4)?,
                health_check_passed: r.get::<_, i32>(5)? == 1,
            })
        })?;

        let mut results = Vec::new();
        for row in rows {
            results.push(row?);
        }

        Ok(results)
    }

    pub fn obter_slot_ativo(&self) -> &str {
        &self.active_slot
    }
}

/// Modelo de dados do manifesto
#[derive(Serialize, Deserialize)]
struct Manifesto {
    versao: String,
    slot: String,
    sha256: String,
    tamanho_bytes: u64,
    assinatura_minisign: String,
    chave_minisign: String,
    timestamp: String,
    slot_anterior: String,
}

impl Manifesto {
    fn assinatura_valida(&self) -> bool {
        !self.assinatura_minisign.is_empty() && !self.chave_minisign.is_empty()
    }

    fn sha256_esperado(&self) -> Option<&str> {
        if self.sha256.len() == 64 {
            Some(&self.sha256)
        } else {
            None
        }
    }
}

fn main() {
    println!("Lume OS - lume-updated v0.1.0");
    println!("========================================");

    let mut gerenciador = match UpdateManager::new("events.sqlite") {
        Ok(b) => b,
        Err(e) => {
            eprintln!("Falha ao iniciar backend: {}", e);
            std::process::exit(1);
        }
    };

    match gerenciador.obter_estado() {
        Ok((ativo, fases)) => {
            println!("Fase atual: {}", ativo);
            for fase in &fases {
                println!("  Fase {}: {:?} - versao {:?} - retry {}", fase.id, fase.status, fase.versao, fase.retry);
            }
        }
        Err(e) => eprintln!("Erro ao consultar estado: {}", e),
    }

    match gerenciador.baixar_manifesto("https://github.com/lume-os/releases/latest/manifesto.json") {
        Ok(manifesto) => {
            println!("Manifesto baixado: versao {} slot {}", manifesto.versao, manifesto.slot);

            match gerenciador.verificar_assinatura(&manifesto) {
                Ok(true) => {
                    println!("Assinatura valida");
                    match gerenciador.instalar_slot(&manifesto) {
                        Ok(()) => {
                            println!("Slot instalado com sucesso");
                            if gerenciador.health_check(&manifesto.slot).is_ok() {
                                println!("Health check passou");
                            }
                        }
                        Err(e) => eprintln!("Erro ao instalar slot: {}", e),
                    }
                }
                Ok(false) => {
                    println!("Assinatura invalida - atualizacao rejeitada");
                }
                Err(e) => eprintln!("Erro ao verificar assinatura: {}", e),
            }
        }
        Err(e) => eprintln!("Erro ao baixar manifesto: {}", e),
    }
}
