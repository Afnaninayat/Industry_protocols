# AMBA Protocol Implementations & Verification

A modular repository featuring register-transfer level (RTL) implementations, gate-level schematic designs, and behavioral verification testbenches for ARM® AMBA industry-standard on-chip communication protocols (**APB** and **AXI**).

Designed as a digital IC design and verification showcase, this repository demonstrates bus transaction workflows, multi-channel handshaking mechanisms, peripheral interfacing, and waveform analysis using industry-standard EDA tools.

---

## 📑 Table of Contents
- [Protocols Covered](#-protocols-covered)
- [Repository Structure](#-repository-structure)
- [Protocol Specifications](#-protocol-specifications)
  - [1. AMBA APB (Advanced Peripheral Bus)](#1-amba-apb-advanced-peripheral-bus)
  - [2. AMBA AXI (Advanced eXtensible Interface)](#2-amba-axi-advanced-extensible-interface)
- [EDA Tools & Technologies](#️-eda-tools--technologies)
- [Simulation & Build Instructions](#-simulation--build-instructions)
- [Verification Strategy](#-verification-strategy)
- [Roadmap](#-roadmap)
- [Author & Contact](#-author--contact)

---

## 📚 Protocols Covered

| Protocol | Full Name | Specification Focus | Implementation | Verification Suite |
| :--- | :--- | :--- | :--- | :--- |
| **APB** | Advanced Peripheral Bus | Low-power, unpipelined peripheral bus | Verilog HDL / Logisim | Directed Testbenches, Waveform PDFs |
| **AXI** | Advanced eXtensible Interface | High-performance, concurrent 5-channel bus | Synthesizable Verilog RTL | Modular Testbench (`tb_axi.v`), Lab Reports |

---

## 📁 Repository Structure

```text
Industry_protocol/
├── AMBA_APB/
│   └── RTL & Simulation Files/
│       ├── Task - 1/
│       │   └── APB/                     # Baseline APB Master/Slave RTL & Waveforms
│       │       ├── *.v
│       │       └── Screenshots.pdf
│       ├── Task - 2/
│       │   └── Counter_slave/           # Register-mapped Counter Slave peripheral
│       │       ├── *.v
│       │       └── Screenshots.pdf
│       └── Task - 3/                    # Gate-level schematic implementation
│           ├── Master_Slave_APB.circ
│           └── Screenshots.pdf
│
├── AMBA_AXI/
│   ├── RTL/                             # Synthesizable AXI master/slave infrastructure
│   │   ├── axi_master.v
│   │   ├── axi_slave.v
│   │   ├── axi_top.v
│   │   └── tb_axi.v
│   └── PDF/
│       └── Lab 03 (AMBA-AXI).pdf        # Detailed protocol & verification analysis
│
└── README.md
