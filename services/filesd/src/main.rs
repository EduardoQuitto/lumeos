use chrono::Utc;
use rusqlite::{Connection, params};
use serde::{Deserialize, Serialize};
use std::fs;
use std::path::Path;

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ArquivoInfo {
    pub caminho: String,
    pub tamanho: u64,
    pub hash_sha256: String,
    pub ultimo_acesso: String,
    pub ultima_modificacao: String,
    pub tipo: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum OperacaoArquivo {
    Criar,
    Ler,
    Atualizar,
    Excluir,
    Montar,
    Desmontar,
    Extrair,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OperacaoArquivoEvento {
    pub operacao: OperacaoArquivo,
    pub caminho: String,
    pub timestamp: String,
    pub usuario: String,
    pub sucesso: bool,
    pub mensagem: String,
}

pub struct FilesD {
    db: Connection,
    raiz_montagem: String,
}

impl FilesD {
    pub fn novo(caminho_db: &str, raiz_montagem: &str) -> Result<Self, Box<dyn std::error::Error>> {
        let db = Connection::open(caminho_db)?;
        db.execute_batch(
            "CREATE TABLE IF NOT EXISTS arquivos (
                caminho TEXT PRIMARY KEY,
                tamanho INTEGER,
                sha256 TEXT,
                ultimo_acesso TEXT,
                ultima_modificacao TEXT,
                tipo TEXT
            );
            CREATE TABLE IF NOT EXISTS operacoes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                operacao TEXT,
                caminho TEXT,
                timestamp TEXT,
                usuario TEXT,
                sucesso INTEGER,
                mensagem TEXT
            );",
        )?;

        Ok(Self {
            db,
            raiz_montagem: raiz_montagem.to_string(),
        })
    }

    pub fn listar_diretorio(&mut self, caminho: &str) -> Result<Vec<ArquivoInfo>, Box<dyn std::error::Error>> {
        let caminho_completo = format!("{}{}", self.raiz_montagem, caminho);
        let mut arquivos = Vec::new();

        if let Ok(entries) = fs::read_dir(&caminho_completo) {
            for entrada in entries.flatten() {
                let caminho = entrada.path();
                if caminho.is_file() {
                    if let Ok(metadata) = caminho.metadata() {
                        arquivos.push(ArquivoInfo {
                            caminho: caminho.to_string_lossy().to_string(),
                            tamanho: metadata.len(),
                            sha256: Self::calcular_sha256(&caminho),
                            ultimo_acesso: Utc::now().to_rfc3339(),
                            ultima_modificacao: Utc::now().to_rfc3339(),
                            tipo: "arquivo".to_string(),
                        });
                    }
                }
            }
        }

        Ok(arquivos)
    }

    fn calcular_sha256(caminho: &Path) -> String {
        use std::fs::File;
        use std::io::Read;

        if let Ok(mut arquivo) = File::open(caminho) {
            let mut hasher = Sha256::new();
            let mut buffer = [0; 8192];
            loop {
                match arquivo.read(&mut buffer) {
                    Ok(0) => break,
                    Ok(n) => hasher.update(&buffer[..n]),
                    Err(_) => break,
                }
            }
            format!("{:x}", hasher.finalize())
        } else {
            "".to_string()
        }
    }

    pub fn montar_dispositivo(&mut self, dispositivo: &str, ponto_montagem: &str) -> Result<bool, Box<dyn std::error::Error>> {
        let resultado = std::process::Command::new("mount")
            .arg(&dispositivo)
            .arg(ponto_montagem)
            .output();

        if resultado.is_ok() && resultado.unwrap().status.success() {
            Ok(true)
        } else {
            Ok(false)
        }
    }

    pub fn desmontar_dispositivo(&mut self, ponto_montagem: &str) -> Result<bool, Box<dyn std::error::Error>> {
        let resultado = std::process::Command::new("umount")
            .arg(ponto_montagem)
            .output();

        if resultado.is_ok() && resultado.unwrap().status.success() {
            Ok(true)
        } else {
            Ok(false)
        }
    }

    pub fn extrair_arquivo(&mut self, arquivo: &str, destino: &str) -> Result<bool, Box<dyn std::error::Error>> {
        let resultado = std::process::Command::new("7z")
            .arg("x")
            .arg(&arquivo)
            .arg(format!("-o{}", destino))
            .output();

        if resultado.is_ok() && resultado.unwrap().status.success() {
            Ok(true)
        } else {
            Ok(false)
        }
    }

    pub fn listar_arquivos(&mut self, diretorio: &str) -> Result<Vec<ArquivoInfo>, Box<dyn std::error::Error>> {
        let caminho_completo = format!("{}{}", self.raiz_montagem, diretorio);
        let mut arquivos = Vec::new();

        if let Ok(entries) = fs::read_dir(&caminho_completo) {
            for entrada in entries.flatten() {
                let caminho = entrada.path();
                if caminho.is_file() {
                    if let Ok(metadata) = caminho.metadata() {
                        arquivos.push(ArquivoInfo {
                            caminho: caminho.to_string_lossy().to_string(),
                            tamanho: metadata.len(),
                            sha256: Self::calcular_sha256(&caminho),
                            ultimo_acesso: Utc::now().to_rfc3339(),
                            ultima_modificacao: Utc::now().to_rfc3339(),
                            tipo: "arquivo".to_string(),
                        });
                    }
                }
            }
        }

        Ok(arquivos)
    }

    pub fn registrar_operacao(&mut self, operacao: OperacaoArquivo, caminho: &str, sucesso: bool, mensagem: &str) -> Result<(), Box<dyn std::error::Error>> {
        self.db.execute(
            "INSERT INTO operacoes (operacao, caminho, timestamp, usuario, sucesso, mensagem) VALUES (?1, ?2, ?3, ?4, ?5, ?6)",
            rusqlite::params![
                format!("{:?}", operacao),
                caminho,
                Utc::now().to_rfc3339(),
                "agente",
                sucesso,
                mensagem
            ],
        )?;
        Ok(())
    }

    pub fn listar_operacoes(&mut self) -> Result<Vec<OperacaoArquivoEvento>, Box<dyn std::error::Error>> {
        let mut stmt = self.db.prepare(
            "SELECT operacao, caminho, timestamp, usuario, sucesso, mensagem FROM operacoes ORDER BY timestamp DESC LIMIT 100"
        )?;
        let rows = stmt.query_map([], |r| {
            Ok(OperacaoArquivoEvento {
                operacao: match r.get::<_, String>(0)?.as_str() {
                    "Criar" => OperacaoArquivo::Criar,
                    "Ler" => OperacaoArquivo::Ler,
                    "Atualizar" => OperacaoArquivo::Atualizar,
                    "Excluir" => OperacaoArquivo::Excluir,
                    "Montar" => OperacaoArquivo::Montar,
                    "Desmontar" => OperacaoArquivo::Desmontar,
                    "Extração" => OperacaoArquivo::Extração,
                    _ => OperacaoArquivo::Ler,
                },
                caminho: r.get(1)?,
                tarefa: r.get(2)?,
                payload: serde_json::json!({ "usuario": r.get::<_, String>(3)?, "sucesso": r.get::<_, bool>(4)?, "mensagem": r.get::<_, String>(5)? }),
            })
        })?;

        let mut eventos = Vec::new();
        for evento in rows {
            eventos.push(evento?);
        }

        Ok(eventos)
    }
}

fn main() {
    println!("Lume OS - lume-filesd v0.1.0");
    println!("========================================");

    let mut daemon = match FilesD::novo("filesd.sqlite", "/mnt/lume") {
        Ok(b) => b,
        Err(e) => {
            eprintln!("Falha ao iniciar backend: {}", e);
            std::process::exit(1);
        }
    };

    match daemon.listar_arquivos("/") {
        Ok(arquivos) => {
            println!("Arquivos na raiz:");
            for arquivo in &arquivos {
                println!("  {} ({} bytes) - {}", arquivo.caminho, arquivo.tamanho, arquivo.tipo);
            }
        }
        Err(e) => eprintln!("Erro ao listar arquivos: {}", e),
    }

    println!("\nServiço filesd iniciado com sucesso!");
}
