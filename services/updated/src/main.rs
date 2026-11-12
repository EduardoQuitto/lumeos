use serde::Serialize;

#[derive(Serialize)]
struct Status {
    service: String,
    version: String,
    status: String,
}

fn main() {
    let status = Status {
        service: "lume-updated".to_string(),
        version: "0.1.0".to_string(),
        status: "running".to_string(),
    };
    println!("{}", serde_json::to_string(&status).unwrap());
    println!("lume-updated: gerenciador de update A/B com rollback automático");
    println!("  Canal: stable");
    println!("  Manifesto: minisign (assinatura offline pelo usuário)");
    println!("  Slot: A (ativo) / B (inativo)");
    println!("  Rollback: automático após 2 boots com falha");
}
