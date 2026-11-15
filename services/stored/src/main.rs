use chrono::Utc;
use rusqlite::{Connection, params};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::fs;
use std::path::Path;

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct SlotInfo {
    pub nome: String,
    pub status: String,
    pub versao: Option<String>,
    pub sha256: Option<String>,
    pub boot_count: u32,
    pub health_check_passed: bool,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ArmazenamentoInfo {
    pub slot_ativo: String,
    pub slots: Vec<SlotInfo>,
    pub espaco_total: u64,
    pub espaco_usado: u64,
    pub espaco_livre: u64,
}

pub struct Stored {
    db: Connection,
    slot_ativo: String,
}

impl Stored {
    pub fn novo(caminho_db: &str) -> Result<Self, Box<dyn std::error::Error>> {
        let db = Connection::open(caminho_db)?;
        db.execute_batch(
            "CREATE TABLE IF NOT EXISTS slots (
                name TEXT PRIMARY KEY,
                status TEXT,
                versao TEXT,
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

        let slot_ativo = Self::obter_slot_ativo(&db)?;

        Ok(Self {
            db,
            slot_ativo,
        })
    }

    fn obter_slot_ativo(db: &Connection) -> Result<String, Box<dyn std::error::Error>> {
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

        self.slot_ativo = slot.to_string();
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
}

fn main() {
    println!("Lume OS - lume-stored v0.1.0");
    println!("========================================");

    let mut armazenamento = match Stored::novo("stored.db") {
        Ok(b) => b,
        Err(e) => {
            eprintln!("Falha ao iniciar armazenamento: {}", e);
            std::process::exit(1);
        }
    };

    // Listar slots
    match armazenamento.listar_slots() {
        Ok(slots) => {
            println!("Slots de armazenamento:");
            for slot in &slots {
                println!("  Slot {}: {} - versão {:?} - boot_count: {} - saudável: {}", 
                    slot.nome, slot.status, slot.versao, slot.boot_count, slot.health_check_passed);
            }
        }
        Err(e) => eprintln!("Erro ao listar slots: {}", e),
    }

    // Obter estatísticas de armazenamento
    match armazenamento.obter_espaco_disponível() {
        Ok(total) => println!("Espaço total: {} bytes ({} GB)", total, total / (1024 * 1024 * 1024)),
        Err(e) => eprintln!("Erro ao obter espaço total: {}", e),
    }

    match armazenamento.obter_espaco_usado() {
        Ok(usado) => println!("Espaço usado: {} bytes ({} MB)", usado, usado / (1024 * 1024)),
        Err(e) => eprintln!("Erro ao obter espaço usado: {}", e),
    }

    match armazenamento.obter_espaco_livre() {
        Ok(livre) => println!("Espaço livre: {} bytes ({} MB)", livre, livre / (1024 * 1024)),
        Err(e) => eprintln!("Erro ao obter espaço livre: {}", e),
    }

    println!("\nArmazenamento Lume OS inicializado com sucesso!");
}
