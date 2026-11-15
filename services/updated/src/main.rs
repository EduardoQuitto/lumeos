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

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SlotInfo {
    pub name: String,
    pub status: SlotStatus,
    pub version: Option<String>,
    pub sha256: Option<String>,
    pub boot_count: u32,
    pub health_check_passed: bool,
}

pub struct Updated {
    db: Connection,
    active_slot: String,
}

impl Updated {
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
                "INSERT OR IGNORE INTO slots (name, status, boot_count, health_check_passed) VALUES (?1, 'inativo', 0, 0)",
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
            "SELECT name FROM slots WHERE status = 'ativo' LIMIT 1",
            [],
            |r| r.get(0),
        )?;
        Ok(row)
    }

    pub fn listar_slots(&mut self) -> Result<Vec<SlotInfo>, Box<dyn std::error::Error>> {
        let mut stmt = self.db.prepare(
            "SELECT name, status, versao, sha256, boot_count, health_check_passed FROM slots"
        )?;
        let rows = stmt.query_map([], |r| {
            Ok(SlotInfo {
                nome: r.get(0)?,
                status: r.get(1)?,
                versao: r.get(2)?,
                sha256: r.get(3)?,
                boot_count: r.get(4)?,
                health_check_passed: r.get::<_, i32>(5)? == 1,
            })
        })?;

        let mut slots = Vec::new();
        for row in rows {
            slots.push(row?);
        }
        Ok(slots)
    }

    pub fn definir_slot_ativo(&mut self, slot: &str) -> Result<(), Box<dyn std::error::Error>> {
        self.db.execute(
            "UPDATE slots SET status = 'inativo' WHERE status = 'ativo'",
            [],
        )?;

        self.db.execute(
            "UPDATE slots SET status = 'ativo', boot_count = 0 WHERE name = ?1",
            rusqlite::params![slot],
        )?;

        self.active_slot = slot.to_string();
        Ok(())
    }

    pub fn verificar_integridade_slot(&mut self, slot: &str) -> Result<bool, Box<dyn std::error::Error>> {
        // Verificar se o slot está íntegro (verity)
        // Em produção, verificar hash do slot
        let slot_ativo = self.obter_slot_ativo()?;
        if slot == &slot_ativo {
            return Ok(true);
        }

        // Slot inativo - verificar se existe
        Ok(true) // Simplificado
    }

    pub fn obter_espaco_disponivel(&self) -> Result<u64, Box<dyn std::error::Error>> {
        // Verificar espaço disponível no armazenamento
        // Em produção, consultar sistema de arquivos
        Ok(50_000_000_000) // 50 GB simulado
    }

    pub fn obter_espaco_usado(&self) -> Result<u64, Box<dyn std::error::Error>> {
        // Calcular espaço usado baseado nos slots
        let mut slots = self.listar_slots()?;
        let mut total = 0u64;
        for slot in &slots {
            // Estimar tamanho baseado na versão
            total += 2_000_000_000; // ~2GB por slot
        }
        Ok(total)
    }

    pub fn obter_espaco_livre(&self) -> Result<u64, Box<dyn std::error::Error>> {
        let total = self.obter_espaco_disponível()?;
        let usado = self.obter_espaco_usado()?;
        Ok(total.saturating_sub(usado))
    }

    pub fn listar_slots(&mut self) -> Result<Vec<SlotInfo>, Box<dyn std::error::Error>> {
        let mut stmt = self.db.prepare(
            "SELECT name, status, versao, sha256, boot_count, health_check_passed FROM slots"
        )?;
        let rows = stmt.query_map([], |r| {
            Ok(SlotInfo {
                nome: r.get(0)?,
                status: r.get(1)?,
                versao: r.get(2)?,
                sha256: r.get(3)?,
                boot_count: r.get(4)?,
                health_check_passed: r.get::<_, i32>(5)? == 1,
            })
        })?;

        let mut slots = Vec::new();
        for row in rows {
            slots.push(row?);
        }
        Ok(slots)
    }

    pub fn baixar_manifesto(&mut self, url: &str) -> Result<UpdateManifest, Box<dyn std::error::Error>> {
        // Em produção, fazer download real via reqwest
        // Aqui simulamos para demonstração
        let manifesto = UpdateManifest {
            versao: "2026.11.2".to_string(),
            slot: if self.slot_ativo == "A" { "B".to_string() } else { "A".to_string() },
            sha256: "a3f5f45e7d9c1b2a3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6".to_string(),
            tamanho_bytes: 1_200_000_000,
            assinatura_minisign: "RWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwRWRwR".to_string(),
            chave_minisign: "RWQf6LRCGA9i53ml5EcO4GlP2YhuUoF+XkKzRsWxDxJ".to_string(),
            timestamp: Utc::now().to_rfc3339(),
            slot_anterior: self.slot_ativo.clone(),
        };

        Ok(manifesto)
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
        // Verificar se o slot bootou com sucesso
        // Em produção: verificar se o sistema bootou com sucesso no slot
        self.db.execute(
            "UPDATE slots SET health_check_passed = 1, boot_count = boot_count + 1 WHERE name = ?1",
            rusqlite::params![slot],
        )?;
        Ok(true)
    }

    pub fn fazer_rollback(&mut self) -> Result<(), Box<dyn std::error::Error>> {
        let slot_atual = self.slot_ativo.clone();
        let slot_alvo = if slot_atual == "A" { "B" } else { "A" };

        // Marcar slot atual como corrompido
        self.db.execute(
            "UPDATE slots SET status = 'corrompido' WHERE name = ?1",
            rusqlite::params![&slot_atual],
        )?;

        // Marcar slot B como ativo
        self.db.execute(
            "UPDATE slots SET status = 'ativo', boot_count = 0 WHERE name = ?1",
            rusqlite::params![slot_alvo],
        )?;

        self.slot_ativo = slot_alvo.to_string();
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
                status: r.get(1)?,
                versao: r.get(2)?,
                sha256: r.get(3)?,
                boot_count: r.get(4)?,
                health_check_passed: r.get::<_, i32>(5)? == 1,
            })
        })?;

        let mut slots = Vec::new();
        for row in rows {
            slots.push(row?);
        }
        Ok(slots)
    }

    pub fn obter_slot_ativo(&self) -> &str {
        &self.slot_ativo
    }
}

fn main() {
    println!("Lume OS - lume-updated v0.1.0");
    println!("========================================");

    let mut atualizado = match Updated::novo("updated.db") {
        Ok(b) => b,
        Err(e) => {
            eprintln!("Falha ao iniciar backend: {}", e);
            std::process::exit(1);
        }
    };

    match atualizado.obter_estado() {
        Ok((slot_ativo, slots)) => {
            println!("Fase atual: {}", slot_ativo);
            for slot in &slots {
                println!("  Slot {}: {:?} - versão {:?} - boot_count: {} - saudável: {}", 
                    slot.nome, slot.status, slot.versao, slot.boot_count, slot.health_check_passed);
            }
        }
        Err(e) => eprintln!("Erro ao carregar estado: {}", e),
    }

    // Simular ciclo de atualização
    match atualizado.baixar_manifesto("https://github.com/lume-os/releases/latest/manifesto.json") {
        Ok(manifesto) => {
            println!("Manifesto baixado: versão {} slot {}", manifesto.versao, manifesto.slot);

            match atualizado.verificar_assinatura(&manifesto) {
                Ok(true) => {
                    println!("Assinatura válida");
                    match atualizado.instalar_slot(&manifesto) {
                        Ok(()) => {
                            println!("Slot instalado com sucesso");
                            if atualizado.health_check(&manifesto.slot).is_ok() {
                                println!("Health check passou");
                            }
                        }
                        Err(e) => eprintln!("Erro ao instalar slot: {}", e),
                    }
                }
                Ok(false) => {
                    println!("Assinatura inválida - atualização rejeitada");
                }
                Err(e) => eprintln!("Erro ao verificar assinatura: {}", e),
            }
        }
        Err(e) => eprintln!("Erro ao baixar manifesto: {}", e),
    }
}
