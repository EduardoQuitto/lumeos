use serde::Serialize;

#[derive(Serialize)]
struct Status {
    service: String,
    version: String,
    status: String,
}

fn main() {
    let status = Status {
        service: "lume-filesd".to_string(),
        version: "0.1.0".to_string(),
        status: "running".to_string(),
    };
    println!("{}", serde_json::to_string(&status).unwrap());
    println!("lume-filesd: daemon de arquivos Lume");
    println!("  Protocolo: D-Bus");
    println!("  Operações: montagem (udisks2), extração (p7zip), lixo");
    println!("  Sidebar: lugares, dispositivos, lixo");
    println!("  Arraste e solte: habilitado");
}
