SSH Hardening Notes

This file contains recommendations and a sample `sshd_config` fragment for hardening SSH on public VPS instances.

Recommended changes (example):

- Disable password authentication where possible and use SSH keys only:
  PasswordAuthentication no
- Disable root login:
  PermitRootLogin no
- Reduce allowed authentication attempts and login grace time:
  MaxAuthTries 4
- Use stronger key exchange and ciphers (example entries may vary across distros):
  KexAlgorithms curve25519-sha256@libssh.org
  Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com

Sample snippet to append to `/etc/ssh/sshd_config`:

```
# SSH hardening (sample)
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
MaxAuthTries 4
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 2
# Ciphers and Kex - verify compatibility with your OpenSSH version
# KexAlgorithms curve25519-sha256@libssh.org
# Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
```

Apply changes and restart sshd:

```bash
sudo systemctl restart sshd
```

Always keep an open session when testing before closing prior connections.
