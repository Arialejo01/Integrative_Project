# Integrative Project — Build, Boot, and Attack

**Course:** UNIX  
**Instructor:** Ing. Jonathan E. Tito O., MSc. — UIDE  
**Term:** March–July 2026

## Team members

| Name | Role |
|------|------|
| Cesar Arciniegas | Part 3 |
| Emilio Cuenca | Part 2 |
| Ariel Guerrero | Part 1 |

---

## Repository structure

```
Integrative_Project/
├── part1-distro/     # Part 1 — Custom distro built with Cubic
├── part2-kernel/     # Part 2 — 64-bit kernel from scratch
└── part3-lab/        # Part 3 — Black Hat Bash offensive lab
```

## How to reproduce each part

### Part 1 — Distro (Cubic)

### Part 2 — 64-bit Kernel

```bash
cd part2-kernel
docker build -t uide-kernel-builder . && docker run --rm -v "$(pwd)":/root/kernel uide-kernel-builder make build-kernel
qemu-system-x86_64 -cdrom kernel.iso
```

See [part2-kernel/README.md](part2-kernel/README.md) for full details.

### Part 3 — Black Hat Bash Lab
See [part3-lab/README.md](part3-lab/README.md)

---

## Global rubric

| Component | Pts |
|---|---|
| Part 1 — Distro with Cubic | 25 |
| Part 2 — 64-bit kernel | 30 |
| Part 3.A — Lab up and running | 20 |
| Part 3.B — Hacking technique | 15 |
| Documentation, repo, and teamwork | 10 |
| **Total** | **100** |
