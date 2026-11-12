use serde::{Deserialize, Serialize};
use std::fs;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Hardware {
    pub cpu_cores: u32,
    pub ram_mb: u64,
    pub gpu_vendor: String,
    pub gpu_model: String,
    pub va_api: bool,
    pub gles32: bool,
    pub is_vm: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TierInfo {
    pub tier: String,
    pub edition: String,
    pub arch: String,
    pub materials: Vec<String>,
    pub idle_mb: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DetectResult {
    pub hardware: Hardware,
    pub tier: TierInfo,
}

fn detect_hardware() -> Hardware {
    // Detecção simplificada — em produção leria /proc/cpuinfo, /proc/meminfo,
    // lspci, glxinfo, virt-what, etc.
    let cpu_cores = num_cpus::get() as u32;
    let ram_mb = sysinfo::System::new().total_memory() / 1024 / 1024;
    let is_vm = detect_vm();
    let gpu_vendor = "intel".to_string();
    let gpu_model = "UHD Graphics 630".to_string();
    let va_api = true;
    let gles32 = true;

    Hardware {
        cpu_cores,
        ram_mb,
        gpu_vendor,
        gpu_model,
        va_api,
        gles32,
        is_vm,
    }
}

fn detect_vm() -> bool {
    // Verifica indicadores comuns de VM
    let indicators = [
        "/sys/class/dmi/id/product_name",
        "/sys/class/dmi/id/sys_vendor",
        "/proc/1/cgroup",
    ];
    for path in &indicators {
        if let Ok(content) = fs::read_to_string(path) {
            let lower = content.to_lowercase();
            if lower.contains("qemu")
                || lower.contains("kvm")
                || lower.contains("virtualbox")
                || lower.contains("vmware")
                || lower.contains("hyperv")
            {
                return true;
            }
        }
    }
    false
}

fn classify_tier(hw: &Hardware) -> TierInfo {
    // VM → Core padrão (conforme PRD §2)
    if hw.is_vm {
        return TierInfo {
            tier: "core".to_string(),
            edition: "Core".to_string(),
            arch: "amd64".to_string(),
            materials: vec!["nevoa".to_string(), "solido".to_string()],
            idle_mb: 350,
        };
    }

    // Critérios conforme PRD §2
    if hw.ram_mb >= 4096 && hw.gles32 {
        TierInfo {
            tier: "prime".to_string(),
            edition: "Prime".to_string(),
            arch: "amd64".to_string(),
            materials: vec!["vidro".to_string(), "nevoa".to_string(), "solido".to_string()],
            idle_mb: 450,
        }
    } else if hw.ram_mb < 4096 || !hw.gles32 {
        TierInfo {
            tier: "core".to_string(),
            edition: "Core".to_string(),
            arch: "amd64".to_string(),
            materials: vec!["nevoa".to_string(), "solido".to_string()],
            idle_mb: 350,
        }
    } else {
        // Lite (i386) — fallback para hardware muito fraco
        TierInfo {
            tier: "lite".to_string(),
            edition: "Lite".to_string(),
            arch: "i386".to_string(),
            materials: vec!["vidro-lite".to_string(), "solido".to_string()],
            idle_mb: 250,
        }
    }
}

fn main() {
    let hw = detect_hardware();
    let tier = classify_tier(&hw);
    let result = DetectResult { hardware: hw.clone(), tier };

    println!("{}", serde_json::to_string_pretty(&result).unwrap());

    // Badge no splash/Sobre/loja/lume-fetch
    println!("\nDetecção concluída:");
    println!("  Tier: {}", result.tier.tier);
    println!("  Edição: {}", result.tier.edition);
    println!("  Arquitetura: {}", result.tier.arch);
    println!("  Materiais: {}", result.tier.materials.join(", "));
    println!("  Idle alvo: {} MB", result.tier.idle_mb);
    println!("  VM: {}", hw.is_vm);
    println!("  CPU cores: {}", hw.cpu_cores);
    println!("  RAM: {} MB", hw.ram_mb);
}
