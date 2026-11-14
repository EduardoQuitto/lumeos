use chrono::Utc;
use rusqlite::{Connection, params};
use serde::{Deserialize, Serialize};
use sha2::{Sha256, Digest};
use std::fs;
use std::path::Path;

/// Manifesto de update assinado (minisign)
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct UpdateManifest {
    pub version: String,
    pub slot: String, // "A" ou "B"
    pub sha256: String,
    pub size_bytes: u64,
    pub minisign_sig: String,
    pub minisign_key: String,
    pub timestamp: String,
    pub previous_slot: String,
}

/// Estado do slot A/B
#[derive(Debug, Clone, PartialEq)]
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
                params![slot],
            )?;
        }

        let active_slot = Self::get_active_slot(&db)?;

        Ok(Self {
            db,
            active_slot,
        })
    }

    fn get_active_slot(db: &Connection) -> Result<String, Box<dyn std::error::Error>> {
        let row = db.query_row(
            "SELECT name FROM slots WHERE status = 'active' LIMIT 1",
            [],
            |r| r.get(0),
        )?;
        Ok(row)
    }

    pub fn verificar_slot(&mut self, slot: &str) -> Result<bool, Box<dyn std::error::Error>> {
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
        // Em produção, fazer download real via reqwest
        // Aqui simulamos para demonstração
        let manifest = UpdateManifest {
            version: "2026.11.2".to_string(),
            slot: if self.active_slot == "A" { "B".to_string() } else { "A".to_string() },
            sha256: "a3f5f45...".to_string(), // placeholder
            size_bytes: 1_200_000_000,
            minisign_sig: "RWR...signature...",
            minisign_key: "RWQf6LRCGA9i53ml5EcO4GlP2YhuUoF+X...",
            timestamp: Utc::now().to_rfc3339(),
            previous_slot: self.active_slot.clone(),
        };
        Ok(manifest)
    }

    pub fn verificar_assinatura(&self, manifesto: &UpdateManifest) -> Result<bool, Box<dyn std::error::Error>> {
        // Em produção, verificar assinatura minisign real
        // Aqui simulamos validação
        if manifesto.manifesto_sha256_esperado().is_some() {
            return Ok(true);
        }
        Ok(false)
    }

    pub fn instalar_slot(&mut self, manifesto: &Manifest) -> Result<(), Box<dyn std::error::Error>> {
        let slot_alvo = &manifesto.slot;
        
        // Marcar slot como atualizando
        self.db.execute(
            "UPDATE slots SET status = 'updating' WHERE name = ?1",
            params![slot_alvo],
        )?;

        // Simular gravação da imagem no slot
        // Em produção: baixar imagem, verificar SHA256, gravar no slot
        
        // Atualizar slot com nova versão
        self.db.execute(
            "UPDATE slots SET status = 'verity', version = ?1, sha256 = ?2, boot_count = 0, health_check_passed = 0 WHERE name = ?3",
            params![&manifesto.versao, &manifesto.sha256, slot_alvo],
        )?;

        log::info!("Slot {} atualizado com versão {}", slot_alvo, manifesto.versao);
        Ok(())
    }

    pub fn health_check(&mut self, slot: &str) -> Result<bool, Box<dyn std::error::Error>> {
        // Verificar se o slot bootou com sucesso
        // Em produção: verificar se o sistema bootou com sucesso no slot
        self.db.execute(
            "UPDATE slots SET health_check_passed = 1, boot_count = boot_count + 1 WHERE name = ?1",
            params![slot],
        )?;
        Ok(true)
    }

    pub fn fazer_rollback(&mut self) -> Result<(), Box<dyn std::error::Error>> {
        let slot_atual = self.active_slot.clone();
        let slot_alvo = if slot_atual == "A" { "B" } else { "A" };

        // Marcar slot atual como corrompido
        self.db.execute(
            "UPDATE slots SET status = 'corrupted' WHERE name = ?1",
            params![&slot_atual],
        )?;

        // Marcar slot B como ativo
        self.db.execute(
            "UPDATE slots SET status = 'active', boot_count = 0 WHERE name = ?1",
            params![slot_alvo],
        )?;

        self.active_slot = slot_alvo.to_string();
        log::warn!("Rollback executado: slot {} -> {}", slot_atual, slot_alvo);
        Ok(())
    }

    pub fn obter_estado(&self) -> Result<(String, Vec<SlotInfo>), Box<dyn std::error::Error>> {
        let mut slots = Vec::new();
        let mut stmt = self.db.prepare(
            "SELECT name, status, version, sha256, boot_count, health_check_passed FROM slots"
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
                saúde_verificada: r.get::<_, i32>(5)? == 1,
            })
        })?;

        for linha in stmt.rows() {
            slots.push(linha?);
        }

        Ok((self.ativo.clone(), slots))
    }

    pub fn obter_slot_ativo(&self) -> &str {
        &self.ativo_slot
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
    println!("Lume Updated - Daemon de Update A/B");
    
    match UpdateManager::new("lume-update.db") {
        mut gerenciador => {
            match gerenciador.obter_estado() {
                Ok((ativo, slots)) => {
                    println!("Slot ativo: {}", ativo);
                    for slot in &slots {
                        println!("  Slot {}: {:?} - versão {:?} - boot {}x", 
                                 slot.nome, slot.status, slot.versao, slot.boot_count);
                    }
                }
                Err(e) => {
                    eprintln!("Erro ao carregar estado: {}", e);
                }
            }

            // Simular ciclo de atualização
            match gerenciador.baixar_manifesto("https://github.com/EduardoQuitto/lumeos/releases/latest/manifesto.json") {
                Ok(manifesto) => {
                    println!("Manifesto baixado: versão {} slot {}", manifesto.versao, manifesto.slot);
                    
                    match gerenciador.verificar_assinatura(&manifesto) {
                        Ok(true) => {
                            println!("Assinatura válida");
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
                            eprintln!("Assinatura inválida - atualização rejeitada");
                        }
                        Err(e) => eprintln!("Erro ao verificar assinatura: {}", e),
                    }
                }
                Err(e) => eprintln!("Erro ao baixar manifesto: {}", e),
            }
        }
        Err(e) => {
            eprintln!("Erro ao inicializar gerenciador: {}", e);
        }
    }
}
