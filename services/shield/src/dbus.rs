use zbus::Connection;
use std::time::Duration;

pub async fn run_dbus_service() -> Result<(), Box<dyn std::error::Error>> {
    match Connection::system().await {
        Ok(conn) => {
            println!("[lume-shield] Conectado ao D-Bus do sistema");
            match conn.request_name("io.lume.Shield").await {
                Ok(_) => println!("[lume-shield] Nome io.lume.Shield requisitado"),
                Err(e) => println!("[lume-shield] Erro ao requisitar nome: {}", e),
            }
        }
        Err(e) => {
            println!("[lume-shield] Não foi possível conectar ao D-Bus do sistema: {}", e);
            println!("[lume-shield] Serviço D-Bus será iniciado quando dbus-daemon estiver disponível");
        }
    }

    tokio::time::sleep(Duration::from_secs(5)).await;
    Ok(())
}
