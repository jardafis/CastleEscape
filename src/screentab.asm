IF  !_ZXN
        public  _screenTab
        section RODATA_2

        ; Screen address decoding:
        ;        Hi                Lo
        ; +---------------+ +---------------+
        ; |7|6|5|4|3|2|1|0| |7|6|5|4|3|2|1|0|
        ; +---------------+ +---------------+
        ; |   | |   |     | |     |         |
        ; +---+ +---+-----+ +-----+---------+
        ;   |     |    |       |        |
        ;   |     |    |       |        +-- Character column (0-31)
        ;   |     |    |       +----------- Character row lower bits (0-7)
        ;   |     |    +------------------- Pixel row within character (0-7)
        ;   |     +------------------------ Character row upper bits (0-2)
        ;   +------------------------------ Bank (1 or 3)


        ;
        ; The screen table contains the address of the
        ; first byte of each pixel row of screen memory
        ;
_screenTab:
        dw      0x4000                  ; Row 0
        dw      0x4100                  ; Row 1
        dw      0x4200                  ; Row 2
        dw      0x4300                  ; Row 3
        dw      0x4400                  ; Row 4
        dw      0x4500                  ; Row 5
        dw      0x4600                  ; Row 6
        dw      0x4700                  ; Row 7
        dw      0x4020                  ; Row 8
        dw      0x4120                  ; Row 9
        dw      0x4220                  ; Row 10
        dw      0x4320                  ; Row 11
        dw      0x4420                  ; Row 12
        dw      0x4520                  ; Row 13
        dw      0x4620                  ; Row 14
        dw      0x4720                  ; Row 15
        dw      0x4040                  ; Row 16
        dw      0x4140                  ; Row 17
        dw      0x4240                  ; Row 18
        dw      0x4340                  ; Row 19
        dw      0x4440                  ; Row 20
        dw      0x4540                  ; Row 21
        dw      0x4640                  ; Row 22
        dw      0x4740                  ; Row 23
        dw      0x4060                  ; Row 24
        dw      0x4160                  ; Row 25
        dw      0x4260                  ; Row 26
        dw      0x4360                  ; Row 27
        dw      0x4460                  ; Row 28
        dw      0x4560                  ; Row 29
        dw      0x4660                  ; Row 30
        dw      0x4760                  ; Row 31
        dw      0x4080                  ; Row 32
        dw      0x4180                  ; Row 33
        dw      0x4280                  ; Row 34
        dw      0x4380                  ; Row 35
        dw      0x4480                  ; Row 36
        dw      0x4580                  ; Row 37
        dw      0x4680                  ; Row 38
        dw      0x4780                  ; Row 39
        dw      0x40a0                  ; Row 40
        dw      0x41a0                  ; Row 41
        dw      0x42a0                  ; Row 42
        dw      0x43a0                  ; Row 43
        dw      0x44a0                  ; Row 44
        dw      0x45a0                  ; Row 45
        dw      0x46a0                  ; Row 46
        dw      0x47a0                  ; Row 47
        dw      0x40c0                  ; Row 48
        dw      0x41c0                  ; Row 49
        dw      0x42c0                  ; Row 50
        dw      0x43c0                  ; Row 51
        dw      0x44c0                  ; Row 52
        dw      0x45c0                  ; Row 53
        dw      0x46c0                  ; Row 54
        dw      0x47c0                  ; Row 55
        dw      0x40e0                  ; Row 56
        dw      0x41e0                  ; Row 57
        dw      0x42e0                  ; Row 58
        dw      0x43e0                  ; Row 59
        dw      0x44e0                  ; Row 60
        dw      0x45e0                  ; Row 61
        dw      0x46e0                  ; Row 62
        dw      0x47e0                  ; Row 63
        dw      0x4800                  ; Row 64
        dw      0x4900                  ; Row 65
        dw      0x4a00                  ; Row 66
        dw      0x4b00                  ; Row 67
        dw      0x4c00                  ; Row 68
        dw      0x4d00                  ; Row 69
        dw      0x4e00                  ; Row 70
        dw      0x4f00                  ; Row 71
        dw      0x4820                  ; Row 72
        dw      0x4920                  ; Row 73
        dw      0x4a20                  ; Row 74
        dw      0x4b20                  ; Row 75
        dw      0x4c20                  ; Row 76
        dw      0x4d20                  ; Row 77
        dw      0x4e20                  ; Row 78
        dw      0x4f20                  ; Row 79
        dw      0x4840                  ; Row 80
        dw      0x4940                  ; Row 81
        dw      0x4a40                  ; Row 82
        dw      0x4b40                  ; Row 83
        dw      0x4c40                  ; Row 84
        dw      0x4d40                  ; Row 85
        dw      0x4e40                  ; Row 86
        dw      0x4f40                  ; Row 87
        dw      0x4860                  ; Row 88
        dw      0x4960                  ; Row 89
        dw      0x4a60                  ; Row 90
        dw      0x4b60                  ; Row 91
        dw      0x4c60                  ; Row 92
        dw      0x4d60                  ; Row 93
        dw      0x4e60                  ; Row 94
        dw      0x4f60                  ; Row 95
        dw      0x4880                  ; Row 96
        dw      0x4980                  ; Row 97
        dw      0x4a80                  ; Row 98
        dw      0x4b80                  ; Row 99
        dw      0x4c80                  ; Row 100
        dw      0x4d80                  ; Row 101
        dw      0x4e80                  ; Row 102
        dw      0x4f80                  ; Row 103
        dw      0x48a0                  ; Row 104
        dw      0x49a0                  ; Row 105
        dw      0x4aa0                  ; Row 106
        dw      0x4ba0                  ; Row 107
        dw      0x4ca0                  ; Row 108
        dw      0x4da0                  ; Row 109
        dw      0x4ea0                  ; Row 110
        dw      0x4fa0                  ; Row 111
        dw      0x48c0                  ; Row 112
        dw      0x49c0                  ; Row 113
        dw      0x4ac0                  ; Row 114
        dw      0x4bc0                  ; Row 115
        dw      0x4cc0                  ; Row 116
        dw      0x4dc0                  ; Row 117
        dw      0x4ec0                  ; Row 118
        dw      0x4fc0                  ; Row 119
        dw      0x48e0                  ; Row 120
        dw      0x49e0                  ; Row 121
        dw      0x4ae0                  ; Row 122
        dw      0x4be0                  ; Row 123
        dw      0x4ce0                  ; Row 124
        dw      0x4de0                  ; Row 125
        dw      0x4ee0                  ; Row 126
        dw      0x4fe0                  ; Row 127
        dw      0x5000                  ; Row 128
        dw      0x5100                  ; Row 129
        dw      0x5200                  ; Row 130
        dw      0x5300                  ; Row 131
        dw      0x5400                  ; Row 132
        dw      0x5500                  ; Row 133
        dw      0x5600                  ; Row 134
        dw      0x5700                  ; Row 135
        dw      0x5020                  ; Row 136
        dw      0x5120                  ; Row 137
        dw      0x5220                  ; Row 138
        dw      0x5320                  ; Row 139
        dw      0x5420                  ; Row 140
        dw      0x5520                  ; Row 141
        dw      0x5620                  ; Row 142
        dw      0x5720                  ; Row 143
        dw      0x5040                  ; Row 144
        dw      0x5140                  ; Row 145
        dw      0x5240                  ; Row 146
        dw      0x5340                  ; Row 147
        dw      0x5440                  ; Row 148
        dw      0x5540                  ; Row 149
        dw      0x5640                  ; Row 150
        dw      0x5740                  ; Row 151
        dw      0x5060                  ; Row 152
        dw      0x5160                  ; Row 153
        dw      0x5260                  ; Row 154
        dw      0x5360                  ; Row 155
        dw      0x5460                  ; Row 156
        dw      0x5560                  ; Row 157
        dw      0x5660                  ; Row 158
        dw      0x5760                  ; Row 159
        dw      0x5080                  ; Row 160
        dw      0x5180                  ; Row 161
        dw      0x5280                  ; Row 162
        dw      0x5380                  ; Row 163
        dw      0x5480                  ; Row 164
        dw      0x5580                  ; Row 165
        dw      0x5680                  ; Row 166
        dw      0x5780                  ; Row 167
        dw      0x50a0                  ; Row 168
        dw      0x51a0                  ; Row 169
        dw      0x52a0                  ; Row 170
        dw      0x53a0                  ; Row 171
        dw      0x54a0                  ; Row 172
        dw      0x55a0                  ; Row 173
        dw      0x56a0                  ; Row 174
        dw      0x57a0                  ; Row 175
        dw      0x50c0                  ; Row 176
        dw      0x51c0                  ; Row 177
        dw      0x52c0                  ; Row 178
        dw      0x53c0                  ; Row 179
        dw      0x54c0                  ; Row 180
        dw      0x55c0                  ; Row 181
        dw      0x56c0                  ; Row 182
        dw      0x57c0                  ; Row 183
        dw      0x50e0                  ; Row 184
        dw      0x51e0                  ; Row 185
        dw      0x52e0                  ; Row 186
        dw      0x53e0                  ; Row 187
        dw      0x54e0                  ; Row 188
        dw      0x55e0                  ; Row 189
        dw      0x56e0                  ; Row 190
        dw      0x57e0                  ; Row 191
ENDIF

