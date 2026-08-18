# Task 3: AHB System Block Diagram with 4 Slaves

## 1. Overview

The AHB (Advanced High-performance Bus) system consists of one AHB Master, an address decoder, an AHB multiplexer (MUX), and four AHB Slaves.

The Master initiates read and write transactions. The Decoder determines which slave should respond based on the address, while the MUX selects the response from the active slave and sends it back to the Master.

---

## 2. AHB System Architecture

```text
                         ┌─────────────────────┐
                         │     AHB MASTER      │
                         │                     │
                         │ HADDR               │
                         │ HWDATA              │
                         │ HWRITE              │
                         │ HSIZE               │
                         │ HTRANS              │
                         │ HBURST              │
                         └──────────┬──────────┘
                                    │
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │    AHB DECODER      │
                         │                     │
                         │ Address Decoding    │
                         └──────────┬──────────┘
                                    │
                 ┌──────────────────┼──────────────────┐
                 │                  │                  │
                 ▼                  ▼                  ▼
            HSELx[0]           HSELx[1]           HSELx[2] ... HSELx[3]
                 │                  │                  │
                 ▼                  ▼                  ▼
           ┌──────────┐       ┌──────────┐       ┌──────────┐
           │ SLAVE 1  │       │ SLAVE 2  │       │ SLAVE 3  │
           │  Memory  │       │  Memory  │       │Peripheral│
           └────┬─────┘       └────┬─────┘       └────┬─────┘
                │                  │                  │
                └──────────────────┼──────────────────┘
                                   │
                                   ▼
                            ┌──────────────┐
                            │    AHB MUX   │
                            │              │
                            │ HRDATA       │
                            │ HREADY       │
                            │ HRESP        │
                            └──────┬───────┘
                                   │
                                   ▼
                            ┌──────────────┐
                            │ AHB MASTER   │
                            │   Response   │
                            └──────────────┘

                    ┌──────────┐
                    │ SLAVE 4  │
                    │Peripheral│
                    └──────────┘


# Task 4 — High-Speed and Low-Speed Peripherals in SoC

## Overview

SoC peripherals are commonly divided into **high-speed** and **low-speed** peripherals based on their bandwidth and performance requirements.

## High-Speed Peripherals

| Peripheral | Typical Data Rate | Bus Interface | Application |
|---|---|---|---|
| PCIe | 2.5–32 GT/s/lane | AXI / AXI-Stream | SSDs, GPUs, accelerators |
| USB 3.x | 5–20 Gbps | AXI / AHB | Storage, cameras |
| Ethernet MAC | 100 Mbps–10+ Gbps | AXI / AHB | Networking |
| DDR Controller | Several GB/s | AXI | Main memory |
| SD/eMMC | Mbps–Gbps | AXI / AHB | Storage |

## Low-Speed Peripherals

| Peripheral | Typical Data Rate | Bus Interface | Application |
|---|---|---|---|
| UART | 9.6 Kbps–1 Mbps+ | APB | Debugging, serial communication |
| I2C | 100 Kbps–3.4 Mbps | APB | Sensors, EEPROM, RTC |
| SPI | Mbps–100+ Mbps | APB | Flash, displays, sensors |
| GPIO | Low bandwidth | APB | LEDs, buttons, control |
| Watchdog Timer | Very low | APB | System monitoring/reset |

## AMBA-Based Architecture

```text
                 +---------+
                 |   CPU   |
                 +----+----+
                      |
                 +----v----+
                 |   AXI   |
                 +----+----+
                      |
          +-----------+-----------+
          |           |           |
         DDR         PCIe      Ethernet
                      |
                AXI/APB Bridge
                      |
                 +----v----+
                 |   APB   |
                 +----+----+
                      |
          +-----------+-----------+
          |       |       |       |
        UART     I2C     SPI     GPIO
