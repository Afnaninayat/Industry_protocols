# Industry Protocols

A collection of **RTL implementations, simulations, and verification environments for commonly used industry-standard digital design protocols**.

This repository currently covers two major protocols:

* **APB (Advanced Peripheral Bus)** — simulation and protocol implementation
* **AMBA AXI (Advanced eXtensible Interface)** — Verilog RTL design and testbench

The purpose of this repository is to understand protocol architecture, transaction flow, RTL implementation, and simulation-based verification.

---

## 📁 Repository Structure

```text
industry-protocols/
│
├── APB/
│   └── Advanced_Peripheral_Bus/
│       ├── Master_Slave_APB.circ
│       
│       
│
├── AMBA-AXI/
│   ├── axi_master.v
│   ├── axi_slave.v
│   ├── tb_axi.v
│   ├── axi_top.v
│   └── ...
│
└── README.md
```
---

# 1. APB — Advanced Peripheral Bus

**APB (Advanced Peripheral Bus)** is a low-complexity, low-power bus protocol from the **AMBA family**, primarily designed for connecting low-bandwidth peripherals and configuration registers.

The APB section of this repository contains a **simulation-based implementation** of the protocol.

### APB Work Included

* APB interface
* APB master/slave communication
* Read transactions
* Write transactions
* Reset sequence
* Clock and control signals
* Simulation/testbench environment
* Transaction-level verification

### Typical APB Signals

| Signal    | Description         |
| --------- | ------------------- |
| `PCLK`    | APB clock           |
| `PRESETn` | Active-low reset    |
| `PADDR`   | Address             |
| `PWDATA`  | Write data          |
| `PRDATA`  | Read data           |
| `PWRITE`  | Read/write control  |
| `PSEL`    | Slave select        |
| `PENABLE` | Enable phase        |
| `PREADY`  | Transfer completion |
| `PSLVERR` | Transfer error      |

### APB Transfer

An APB transfer generally consists of two phases:

```text
IDLE
  │
  ▼
SETUP
  │
  ▼
ACCESS
  │
  ├── PREADY = 1 ──► Transfer Complete
  │
  └── PREADY = 0 ──► Wait
```

The APB implementation in this repository demonstrates how these phases are handled during read and write transactions.

---

# 2. AMBA AXI

**AXI (Advanced eXtensible Interface)** is a high-performance protocol from the **AMBA family**, designed for high-speed communication between components in modern SoC and FPGA systems.

The `AMBA-AXI` folder contains a **Verilog RTL implementation** along with a testbench for simulation and verification.

### AXI RTL Components

The AXI implementation includes:

```text
axi_master.v
axi_slave.v
axi_top.v
tb_axi.v
```

### Components

#### `axi_master.v`

Implements the AXI master-side logic responsible for initiating transactions.

Responsibilities include:

* Generating addresses
* Generating write transactions
* Sending write data
* Generating read requests
* Receiving read responses
* Handling AXI handshaking

#### `axi_slave.v`

Implements the AXI slave-side logic responsible for responding to master requests.

Responsibilities include:

* Receiving addresses
* Accepting write data
* Processing read requests
* Returning read data
* Generating responses
* Managing AXI handshaking

#### `axi_top.v`

Top-level RTL module used to connect the AXI master and AXI slave.

```text
             ┌───────────────┐
             │   AXI Master  │
             └───────┬───────┘
                     │
              AXI Interface
                     │
             ┌───────▼───────┐
             │   AXI Slave   │
             └───────────────┘
```

#### `tb_axi.v`

Simulation testbench used to verify the AXI design.

The testbench provides:

* Clock generation
* Reset generation
* AXI transactions
* Write/read stimulus
* Response monitoring
* Simulation output

---

# AXI Channel Architecture

AXI uses separate channels for read and write operations.

### Write Channels

```text
Write Address Channel
        │
        ▼
      AWADDR
        │
        ▼
Write Data Channel
        │
        ▼
      WDATA
        │
        ▼
Write Response Channel
        │
        ▼
       BRESP
```

### Read Channels

```text
Read Address Channel
        │
        ▼
      ARADDR
        │
        ▼
Read Data Channel
        │
        ▼
      RDATA
      RRESP
```

AXI communication uses the **VALID/READY handshake mechanism** to control when a transfer takes place.

---

# 🛠️ Tools & Technologies

This repository primarily uses:

* **Verilog HDL**
* **SystemVerilog**
* **QuestaSim / ModelSim** for simulation
* **RTL design**
* **Digital Design & Verification**
* **AMBA Protocols**

---

# ▶️ Simulation

## APB

Navigate to the APB directory and compile the required source and testbench files using your preferred simulator.

Example with QuestaSim:

```bash
vlog *.sv
vsim work.tb_top
run -all
```

> Use the actual testbench module name present in the APB simulation files.

---

## AMBA AXI

Navigate to the AXI directory:

```bash
cd AMBA-AXI
```

Compile the RTL and testbench:

```bash
vlog axi_master.v axi_slave.v axi_top.v tb_axi.v
```

Start the simulation:

```bash
vsim work.tb_axi
```

Run the simulation:

```text
run -all
```

You can then inspect the AXI transactions using the simulator transcript and waveform viewer.

---

# 🧪 Verification

The repository focuses on understanding and verifying protocol-level behavior through simulation.

The verification process includes:

* Reset verification
* Write transaction verification
* Read transaction verification
* Master/slave communication
* Handshake signals
* Address and data transfer
* Response handling
* Waveform analysis

---

# 📚 Protocols Covered

| Protocol | Category                 | Implementation    | Verification           |
| -------- | ------------------------ | ----------------- | ---------------------- |
| APB      | AMBA Peripheral Bus      | SystemVerilog/RTL | Simulation             |
| AMBA AXI | High-Performance SoC Bus | Verilog RTL       | Testbench + Simulation |

---

# 🎯 Learning Objectives

This repository was developed to strengthen practical understanding of:

* Industry-standard bus protocols
* RTL design using Verilog/SystemVerilog
* Master and slave architectures
* Protocol handshaking
* Read/write transactions
* Testbench development
* Simulation and waveform analysis
* Digital IC design and verification concepts

---

# 🚀 Future Work

Planned improvements may include:

* [ ] More detailed APB verification
* [ ] AXI protocol assertions
* [ ] Functional coverage
* [ ] Constrained-random verification
* [ ] AXI burst transactions
* [ ] AXI-Lite implementation
* [ ] UVM-based verification environment
* [ ] Additional industry-standard protocols such as AHB, SPI, I2C, and UART

---

# 👨‍💻 Author

**Afnan Inayat**

Computer Science | Digital IC Design & Verification

This repository is maintained as a learning and practical implementation project for **industry-standard communication protocols and RTL design**.

---

## ⭐ Repository

If you find this repository useful for learning RTL design, AMBA protocols, or digital verification, consider giving it a ⭐.
