#!/usr/bin/env bash
# Conservative laptop performance: zram, SSD trim, power profiles.
# No kernel parameter changes, no disabled mitigations, no overclocking.

configure_performance() {
  log_info "Applying conservative laptop performance settings"

  _perf_enable_zram
  _perf_enable_fstrim
  _perf_power_profiles
  _perf_skip_aggressive_tweaks

  state_append_list "MODULES" "performance"
}

_perf_enable_zram() {
  if [[ -e /dev/zram0 ]] || systemctl is-active --quiet systemd-zram-setup@zram0 2>/dev/null; then
    log_skip "zram already active"
    return 0
  fi

  log_info "Enabling zram compressed RAM swap. This improves responsiveness on 16 GB laptops."
  log_info "No sysctl swappiness override is applied; Ubuntu defaults are kept."

  if apt_package_available systemd-zram-generator; then
    apt_install_missing systemd-zram-generator
  elif apt_package_available zram-tools; then
    apt_install_missing zram-tools
  elif apt_package_available zram-config; then
    apt_install_missing zram-config
  else
    log_warn "No zram package found in this archive. Skipping zram."
    return 0
  fi

  if is_dry_run; then
    log_dry "enable zram service if present"
    return 0
  fi

  if systemctl list-unit-files | grep -q '^systemd-zram-setup@'; then
    sudo_run systemctl daemon-reload || true
  fi
  log_success "zram package installed"
}

_perf_enable_fstrim() {
  if ! os_has_ssd; then
    log_skip "fstrim.timer (no non-rotational disk detected)"
    return 0
  fi
  log_info "Enabling weekly SSD TRIM (fstrim.timer). This is safe and recommended for SSDs."
  if is_dry_run; then
    log_dry "systemctl enable --now fstrim.timer"
    return 0
  fi
  if sudo_run systemctl enable --now fstrim.timer; then
    log_success "fstrim.timer enabled"
  else
    log_warn "Could not enable fstrim.timer"
  fi
}

_perf_power_profiles() {
  if apt_package_available power-profiles-daemon; then
    apt_install_missing power-profiles-daemon
  fi

  if is_dry_run; then
    log_dry "systemctl enable --now power-profiles-daemon; powerprofilesctl set balanced"
    return 0
  fi

  if systemctl list-unit-files --type=service 2>/dev/null | grep -q '^power-profiles-daemon'; then
    sudo_run systemctl enable --now power-profiles-daemon.service || true
  fi

  if command_exists powerprofilesctl; then
    powerprofilesctl set balanced >/dev/null 2>&1 || true
    log_success "Power profile: balanced (use 'powerprofilesctl set performance' when plugged in and compiling)"
  fi

  log_info "TLP is not installed: it conflicts with power-profiles-daemon on modern Ubuntu."
}

_perf_skip_aggressive_tweaks() {
  log_info "Not changing: CPU mitigations, kernel cmdline, swappiness, overclocking, or CPU governor sysfs."
  log_info "Not disabling: AppArmor, Secure Boot, automatic updates service, or the firewall."
  log_info "Not installing: preload, TLP, or extra background daemons."
}
