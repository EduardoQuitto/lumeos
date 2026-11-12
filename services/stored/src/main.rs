use serde::Serialize;

#[derive(Serialize)]
struct Status {
    service: String,
    version: String,
    status: String,
}

fn main() {
    let status = Status {
        service: "lume-stored".to_string(),
        version: "0.1.0".to_string(),
        status: "running".to_string(),
    };
    println!("{}", serde_json::to_string(&status).unwrap());
    println!("lume-stored: daemon de armazenamento Lume");
    println!("  Base: SquashFS+verity (imutável)");
    println!("  Persistência: LUKS2 ext4 (LUME-DATA)");
    println!("  Slots: slotA.img / slotB.img (kernels por slot)");
    println!("  Swap: zram (zstd)");
    println!("  Hibernação: off padrão");
}
