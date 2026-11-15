use zbus::Connection;
use std::time::Duration;

pub async fn run_dbus_service() -> Result<(), Box<dyn std::error::Error>> {
    match Connection::system().await {
        Ok(conn) => {
            println!("[lume-updated] Conectado ao D-Bus do sistema");
            match conn.request_name("io.lume.Updated").await {
                Ok(_) => println!("[lume-updated] Nome io.lume.Updated requisitado"),
                Err(e) => println!("[lume-updated] Erro ao requisitar nome: {}", e),
            }
        }
        Err(e) => {
            println!("[lume-updated] Não foi possível conectar ao D-Bus do sistema: {}", e);
            println!("[lume-updated] Serviço D-Bus será iniciado quando dbus-daemon estiver disponível");
        }
    }

    tokio::time::sleep(Duration::from_secs(5)).await;
    Ok(())
}
