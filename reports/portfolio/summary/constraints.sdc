
# ==================================================
# AES-128 SDC CONSTRAINTS
# Technology : SKY130A
# Clock      : 100 MHz
# Period     : 10 ns
# ==================================================

# 1. Clock definition
create_clock -name core_clock -period 10 [get_ports clk]

# 2. Clock uncertainty
set_clock_uncertainty 0.2 [get_clocks core_clock]

# 3. Clock transition
set_clock_transition 0.2 [get_clocks core_clock]

# 4. Input delays (external input budget: 2 ns)
set_input_delay -max 2.0 -clock core_clock \
    [get_ports {rst start key[*] plaintext[*]}]

set_input_delay -min 0.0 -clock core_clock \
    [get_ports {rst start key[*] plaintext[*]}]

# 5. Input transition
set_input_transition 0.2 \
    [get_ports {rst start key[*] plaintext[*]}]

# 6. Output delays (external output budget: 2 ns)
set_output_delay -max 2.0 -clock core_clock \
    [get_ports {ciphertext[*] busy done}]

set_output_delay -min 0.0 -clock core_clock \
    [get_ports {ciphertext[*] busy done}]

# ==================================================
# END OF CONSTRAINTS
# ==================================================

