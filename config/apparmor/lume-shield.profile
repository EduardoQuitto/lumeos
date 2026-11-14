# AppArmor profile — Lume OS Shield
# Requisitos fase 21:
#   - AppArmor enforce para daemons e aplicativos

#include <tunables/global>

/usr/bin/lume-detect {
  #include <abstractions/base>
  #include <abstractions/nameservice>

  capability dac_read_search,
  capability net_bind_service,
  capability net_raw,
  capability setuid,
  capability setgid,

  /etc/lume/** r,
  /var/lib/lume/** rw,
  /run/lume/** rw,

  /usr/bin/lume-detect mr,
  /usr/lib/lume/** mr,

  @{PROC}/** mr,
  @{sys}/** r,

  deny /etc/shadow rw,
  deny /etc/sudoers rw,
  deny /root/** rw,
}

# AppArmor para lume-updated
/usr/bin/lume-updated {
  #include <tunables/global>

  capability net_bind_service,
  capability net_raw,

  /etc/lume/** r,
  /var/lib/lume/** rw,
  /run/lume/** rw,
  /var/lib/lume-updated/** rw,

  /usr/bin/lume-updated mr,
  /usr/lib/lume-updated/** mr,

  @{PROC}/** mr,
  @{sys}/** r,

  deny /etc/shadow rw,
  deny /etc/sudoers rw,
  deny /root/** rw,
}

# AppArmor para lume-shield
/usr/bin/lume-shield {
  #include <tunables/global>

  capability net_bind_service,
  capability net_raw,
  capability sys_admin,

  /etc/lume/** r,
  /var/lib/lume-shield/** rw,
  /run/lume-shield/** rw,

  /usr/bin/lume-shield mr,
  /usr/lib/lume-shield/** mr,

  @{PROC}/** mr,
  @{sys}/** r,

  deny /etc/shadow rw,
  deny /etc/sudoers rw,
  deny /root/** rw,
}

# AppArmor para lume-filesd
/usr/bin/lume-filesd {
  #include <tunables/global>

  capability net_bind_service,
  capability net_raw,
  capability dac_read_search,

  /etc/lume/** r,
  /var/lib/lume-filesd/** rw,
  /run/lume-filesd/** rw,
  /media/** rw,
  /mnt/** rw,

  /usr/bin/lume-filesd mr,
  /usr/lib/lume-filesd/** mr,

  @{PROC}/** mr,
  @{sys}/** r,

  deny /etc/shadow rw,
  deny /etc/sudoers rw,
  deny /root/** rw,
}

# AppArmor para lume-stored
/usr/bin/lume-stored {
  #include <tunables/global>

  capability net_bind_service,
  capability net_raw,
  capability sys_admin,
  capability dac_override,

  /etc/lume/** r,
  /var/lib/lume-stored/** rw,
  /run/lume-stored/** rw,
  /mnt/lume/** rw,
  /media/lume/** rw,

  /usr/bin/lume-stored mr,
  /usr/lib/lume-stored/** mr,

  @{PROC}/** mr,
  @{sys}/** r,

  deny /etc/shadow rw,
  deny /etc/sudoers rw,
  deny /root/** rw,
}
