use zbus::Connection;
use std::time::Duration;

pub async fn run_dbus_service() -> Result<(), Box<dyn std::error::Error>> {
    match Connection::system().await {
        Ok(conn) => {
            println!("[lume-stored] Conectado ao D-Bus do sistema");
            match conn.request_name("io.lume.Stored").await {
                Ok(_) => println!("[lume-stored] Nome io.lume.Stored requisitado"),
                Err(e) => println!("[lume-stored] Erro ao requisitar nome: {}", e),
            }
        }
        Err(e) => {
            println!("[lume-stored] Não foi possível conectar ao D-Bus do sistema: {}", e);
            println!("[lume-stored] Serviço D-Bus será iniciado quando dbus-daemon estiver disponível");
        }
    }

    tokio::time::sleep(Duration::from_secs(5)).await;
    Ok(())
}
