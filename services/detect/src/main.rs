use chrono::Utc;
use rusqlite::{Connection, params};
use serde::{Deserialize, Serialize};
use std::fs;
use std::path::Path;

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct HardwareInfo {
    pub cpu_arch: String,
    pub cpu_cores: u32,
    pub cpu_threads: u32,
    pub cpu_model: String,
    pub ram_mb: u64,
    pub gpu_vendor: String,
    pub gpu_model: String,
    pub gpu_vram_mb: u64,
    pub has_vaapi: bool,
    pub has_gles32: bool,
    pub is_vm: bool,
    pub is_virtio: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum HardwareTier {
    Prime,
    Core,
    Lite,
}

impl HardwareInfo {
    pub fn detect() -> Self {
        let cpu_arch = detect_cpu_arch();
        let (cpu_cores, cpu_threads, cpu_model) = detect_cpu();
        let ram_mb = detect_ram();
        let (gpu_vendor, gpu_model, gpu_vram_mb, has_vaapi, has_gles32) = detect_gpu();
        let (is_vm, is_virtio) = detect_vm();

        HardwareInfo {
            cpu_arch,
            cpu_cores,
            cpu_threads,
            cpu_model,
            ram_mb,
            gpu_vendor,
            gpu_model,
            gpu_vram_mb,
            has_vaapi,
            has_gles32,
            is_vm,
            is_virtio,
        }
    }

    pub fn classify_tier(&self) -> HardwareTier {
        if self.is_vm {
            return HardwareTier::Core;
        }

        if self.cpu_arch == "i386" || self.cpu_arch == "i686" {
            return HardwareTier::Lite;
        }
        if self.ram_mb < 2048 || !self.has_gles32 || !self.has_vaapi {
            return HardwareTier::Lite;
        }

        if self.ram_mb >= 4096 && self.has_gles32 && self.has_vaapi {
            return HardwareTier::Prime;
        }

        HardwareTier::Core
    }

    pub fn tier_name(&self) -> &'static str {
        match self.tier() {
            HardwareTier::Prime => "Prime",
            HardwareTier::Core => "Core",
            HardwareTier::Lite => "Lite",
        }
    }

    fn tier(&self) -> HardwareTier {
        self.classify_tier()
    }
}

fn detect_cpu_arch() -> String {
    if let Ok(content) = fs::read_to_string("/proc/cpuinfo") {
        for line in content.lines() {
            if line.starts_with("model name") || line.starts_with("processor") {
                if line.contains("i386") || line.contains("i686") {
                    return "i386".to_string();
                }
                if line.contains("x86_64") {
                    return "amd64".to_string();
                }
                if line.contains("aarch64") || line.contains("aarch64_be") {
                    return "aarch64".to_string();
                }
            }
        }
    }
    if let Ok(output) = std::process::Command::new("uname").arg("-m").output() {
        let arch = String::from_utf8_lossy(&output.stdout).trim().to_string();
        return arch;
    }
    "amd64".to_string()
}

fn detect_cpu() -> (u32, u32, String) {
    let mut cpu_cores = 0u32;
    let mut cpu_threads = 0u32;
    let mut cpu_model = "Unknown".to_string();

    if let Ok(content) = fs::read_to_string("/proc/cpuinfo") {
        for line in content.lines() {
            if line.starts_with("model name") {
                if let Some(name) = line.split(':').nth(1) {
                    model = name.trim().to_string();
                }
            }
            if line.starts_with("processor") {
                cpu_threads += 1;
            }
            if line.starts_with("cpu cores") {
                if let Some(cores_str) = line.split(':').nth(1) {
                    if let Ok(c) = cores_str.trim().parse::<u32>() {
                        cpu_cores = c;
                    }
                }
            }
        }
    }
    if cpu_cores == 0 {
        if let Ok(output) = std::process::Command::new("nproc").output() {
            if let Ok(cores) = String::from_utf8(output.stdout).ok() {
                if let Ok(c) = cores.trim().parse::<u32>() {
                    cpu_cores = c;
                    cpu_threads = c;
                }
            }
        }
    }
    (cpu_cores, cpu_threads, cpu_model)
}

fn detect_ram() -> u64 {
    if let Ok(content) = fs::read_to_string("/proc/meminfo") {
        for line in content.lines() {
            if line.starts_with("MemTotal:") {
                if let Some(kb_str) = line.split(':').nth(1) {
                    if let Ok(kb) = kb_str.trim().split_whitespace().next().unwrap().parse::<u64>() {
                        return kb / 1024;
                    }
                }
            }
        }
    }
    if let Ok(output) = std::process::Command::new("free").arg("-m").output() {
        let output_str = String::from_utf8_lossy(&output.stdout);
        for line in output_str.lines() {
            if line.starts_with("Mem:") {
                if let Some(mb) = line.split_whitespace().nth(1) {
                    if let Ok(mb_val) = mb.parse::<u64>() {
                        return mb_val;
                    }
                }
            }
        }
    }
    2048
}

fn detect_gpu() -> (String, String, u64, bool, bool) {
    let mut gpu_vendor = "Unknown".to_string();
    let mut gpu_model = "Unknown".to_string();
    let mut gpu_vram_mb = 0u64;
    let mut has_vaapi = false;
    let mut has_gles32 = false;

    if let Ok(output) = std::process::Command::new("lspci").arg("-k").output() {
        let output_str = String::from_utf8_lossy(&output.stdout);
        for line in output_str.lines() {
            if line.contains("VGA") || line.contains("3D controller") || line.contains("Display controller") {
                if let Some((vendor, model)) = parse_gpu_info(line) {
                    gpu_vendor = vendor;
                    gpu_model = model;
                }
            }
        }
    }

    has_vaapi = check_vaapi();
    has_gles32 = check_gles32();

    (gpu_vendor, gpu_model, gpu_vram_mb, has_vaapi, has_gles32)
}

fn detect_vm() -> (bool, bool) {
    let mut is_vm = false;
    let mut is_virtio = false;

    if let Ok(content) = fs::read_to_string("/sys/class/dmi/id/product_name") {
        let name = content.trim().to_lowercase();
        if name.contains("qemu") || name.contains("kvm") || name.contains("virtualbox") || name.contains("vmware") || name.contains("xen") || name.contains("hyperv") {
            is_vm = true;
        }
    }

    if let Ok(content) = fs::read_to_string("/sys/class/dmi/id/product_name") {
        if content.to_lowercase().contains("virtio") {
            is_virtio = true;
        }
    }

    if let Ok(content) = fs::read_to_string("/proc/cpuinfo") {
        if content.to_lowercase().contains("hypervisor") {
            is_vm = true;
        }
    }

    (is_vm, is_virtio)
}

fn detect_vaapi() -> bool {
    if std::process::Command::new("vainfo").output().is_ok() {
        return true;
    }
    if std::path::Path::new("/usr/lib/x86_64-linux-gnu/dri/i965_drv_video.so").exists()
        || std::path::Path::new("/usr/lib/x86_64-linux-gnu/dri/i965_drv_video.so").exists()
    {
        return true;
    }
    false
}

fn detect_gles32() -> bool {
    if std::path::Path::new("/usr/lib/x86_64-linux-gnu/dri/i965_dri.so").exists()
        || std::path::Path::new("/usr/lib/x86_64-linux-gnu/dri/iris_dri.so").exists()
        || std::path::Path::new("/usr/lib/x86_64-linux-gnu/dri/radeonsi_dri.so").exists()
    {
        return true;
    }
    false
}

fn parse_gpu_info(line: &str) -> Option<(String, String)> {
    let parts: Vec<&str> = line.split(':').collect();
    if parts.len() >= 3 {
        let desc = parts[2].trim();
        let vendor = if desc.contains("NVIDIA") {
            "NVIDIA"
        } else if desc.contains("AMD") || desc.contains("ATI") {
            "AMD"
        } else if desc.contains("Intel") {
            "Intel"
        } else {
            "Unknown"
        };
        (vendor.to_string(), desc.to_string())
    } else {
        None
    }
}

fn main() {
    println!("Lume OS - lume-detect v0.1.0");
    println!("========================================");

    let detect = HardwareInfo::new();
    let tier = detect.classify_tier();

    println!();
    println!("=== Detecção de Hardware ===");
    println!("  Arquitetura CPU: {}", detect.cpu_arch);
    println!("  Modelo CPU: {}", detect.cpu_model);
    println!("  CPUs físicas: {}", detect.cpu_cores);
    println!("  CPUs lógicas: {}", detect.cpu_threads);
    println!("  RAM: {} MB", detect.ram_mb);
    println!("  GPU: {} {}", detect.gpu_vendor, detect.gpu_model);
    println!("  VRAM GPU: {} MB", detect.gpu_vram_mb);
    println!("  VA-API: {}", if detect.vaapi { "sim" } else { "não" });
    println!("  GLES 3.2: {}", if detect.gles32 { "sim" } else { "não" });
    println!("  VM: {}", if detect.is_vm { "sim" } else { "não" });
    println!("  Virtio: {}", if detect.is_virtio { "sim" } else { "não" });
    println!();
    println!("=== Classificação de Tier ===");
    println!("  Tier detectado: {} ({})", tier.tier_name(), tier as u8);
    println!("  Justificativa:");
    match tier {
        HardwareTier::Prime => println!("    - RAM >= 4 GB e GLES 3.2 e VA-API presentes"),
        HardwareTier::Core => println!("    - Hardware intermediário (não é Prime nem Lite)"),
        HardwareTier::Lite => println!("    - i386 ou RAM < 4 GB ou sem GLES 3.2/VA-API"),
    }

    println!();
    println!("=== JSON de Saída ===");
    println!("{}", serde_json::to_string_pretty(&detect).unwrap());

    if let Err(e) = fs::write("/var/lib/lume/detect.json", serde_json::to_string_pretty(&detect).unwrap()) {
        eprintln!("Aviso: não foi possível salvar detecção: {}", e);
    }

    println!("\nDetecção concluída com sucesso!");
}
