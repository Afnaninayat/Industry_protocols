# AMBA Protocol Implementations & Verification

A practical RTL design and verification repository focused on **ARM AMBA industry-standard on-chip communication protocols**.

This repository contains **Verilog RTL implementations, simulation environments, digital circuit designs, testbenches, lab documentation, and waveform analysis** for APB, AXI, and AHB protocols.

The project is developed to build hands-on experience in **RTL Design, Digital IC Design, Bus Protocols, Simulation, and Hardware Verification**.

---

## 📚 Protocols Covered

| Protocol | Full Name | Focus | Implementation | Verification |
|:---|:---|:---|:---|:---|
| **APB** | Advanced Peripheral Bus | Low-bandwidth peripheral communication | Verilog / Logisim | RTL Simulation & Circuit Analysis |
| **AXI** | Advanced eXtensible Interface | High-performance SoC communication | Verilog RTL | Testbench & Simulation |
| **AHB** | Advanced High-performance Bus | High-performance system bus | Verilog RTL | Testbench & Simulation |

---

## 📁 Repository Structure

```text
Industry_protocol/
│
├── AMBA_APB/
│   └── RTL & Simulation Files/
│       │
│       ├── Task - 1/
│       │   └── APB/
│       │       ├── Verilog RTL Files
│       │       └── Screenshots
│       │
│       ├── Task - 2/
│       │   └── Counter_slave/
│       │       ├── Verilog RTL Files
│       │       └── Screenshots
│       │
│       └── Task - 3/
│           ├── Master_Slave_APB.circ
│           └── Screenshots
│
├── AMBA_AXI/
│   │
│   ├── RTL/
│   │   ├── axi_master.v
│   │   ├── axi_slave.v
│   │   ├── axi_top.v
│   │   └── tb_axi.v
│   │
│   └── PDF/
│       └── Lab 03 (AMBA-AXI).pdf
│
├── AMBA_AHB/
│   │
│   ├── RTL/
│   │   ├── AHB_Master.v
│   │   ├── AHB_Decoder.v
│   │   ├── AHB_MUX.v
│   │   ├── AHB_Slave_1.v
│   │   ├── AHB_Slave_2.v
│   │   ├── AHB_TOP.v
│   │   └── tb_AHB.v
│   │
│   ├── AMBA AHB Lab - Tasks.pdf
│   └── readme.md
│
├── .gitignore
└── README.md 
```

## 👨‍💻 Author

**Afnan Inayat**

Computer Science | Digital IC Design & Verification

Passionate about **RTL Design, Digital IC Design, Hardware Verification, and Industry-Standard Communication Protocols**.

This repository represents practical work and continuous learning in **industry-standard hardware protocols and digital design verification**.

⭐ If you find this repository useful, consider giving it a **star**.
