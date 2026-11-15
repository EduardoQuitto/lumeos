use zbus::Connection;
use std::time::Duration;

pub async fn run_dbus_service() -> Result<(), Box<dyn std::error::Error>> {
    match Connection::system().await {
        Ok(conn) => {
            println!("[lume-detect] Conectado ao D-Bus do sistema");
            match conn.request_name("io.lume.Detect").await {
                Ok(_) => println!("[lume-detect] Nome io.lume.Detect requisitado"),
                Err(e) => println!("[lume-detect] Erro ao requisitar nome: {}", e),
            }
        }
        Err(e) => {
            println!("[lume-detect] Não foi possível conectar ao D-Bus do sistema: {}", e);
            println!("[lume-detect] Serviço D-Bus será iniciado quando dbus-daemon estiver disponível");
        }
    }

    // Manter vivo por um tempo para demonstração
    tokio::time::sleep(Duration::from_secs(5)).await;
    Ok(())
}
