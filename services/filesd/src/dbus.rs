use zbus::Connection;
use std::time::Duration;

pub async fn run_dbus_service() -> Result<(), Box<dyn std::error::Error>> {
    match Connection::system().await {
        Ok(conn) => {
            println!("[lume-filesd] Conectado ao D-Bus do sistema");
            match conn.request_name("io.lume.Filesd").await {
                Ok(_) => println!("[lume-filesd] Nome io.lume.Filesd requisitado"),
                Err(e) => println!("[lume-filesd] Erro ao requisitar nome: {}", e),
            }
        }
        Err(e) => {
            println!("[lume-filesd] Não foi possível conectar ao D-Bus do sistema: {}", e);
            println!("[lume-filesd] Serviço D-Bus será iniciado quando dbus-daemon estiver disponível");
        }
    }

    tokio::time::sleep(Duration::from_secs(5)).await;
    Ok(())
}
