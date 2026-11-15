use zbus::Connection;
use std::time::Duration;

pub async fn run_cli_dbus_demo() -> Result<(), Box<dyn std::error::Error>> {
    println!("=== Lume CLI via D-Bus ===");

    match Connection::system().await {
        Ok(conn) => {
            println!("Conectado ao bus D-Bus do sistema");

            // Tentar consultar serviços via proxy
            for (name, path, iface) in [
                ("io.lume.Detect", "/io/lume/Detect", "io.lume.Detect"),
                ("io.lume.Shield", "/io/lume/Shield", "io.lume.Shield"),
                ("io.lume.Stored", "/io/lume/Stored", "io.lume.Stored"),
            ] {
                match zbus::Proxy::new(&conn, name, path, iface).await {
                    Ok(_proxy) => println!("Proxy criado para {}", name),
                    Err(e) => println!("Erro ao criar proxy para {}: {}", name, e),
                }
            }
        }
        Err(e) => {
            println!("Não foi possível conectar ao D-Bus do sistema: {}", e);
            println!("Serviços D-Bus estarão disponíveis quando dbus-daemon estiver rodando");
        }
    }

    tokio::time::sleep(Duration::from_secs(2)).await;
    Ok(())
}
