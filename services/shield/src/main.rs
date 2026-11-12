use serde::Serialize;

#[derive(Serialize)]
struct Status {
    service: String,
    version: String,
    status: String,
}

fn main() {
    let status = Status {
        service: "lume-shield".to_string(),
        version: "0.1.0".to_string(),
        status: "running".to_string(),
    };
    println!("{}", serde_json::to_string(&status).unwrap());
    println!("lume-shield: Central de Segurança Lume");
    println!("  Criptografia: LUKS2 (USB+HD)");
    println!("  Verity: slots imutáveis");
    println!("  Secure Boot: lockdown=integrity (B/C)");
    println!("  AppArmor: enforce");
    println!("  seccomp: nos daemons");
    println!("  nftables: default-deny entrada");
    println!("  Telemetria: zero (crash local opt-in)");
    println!("  TPM2: opcional (off padrão)");
}
