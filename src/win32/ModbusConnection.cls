VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ModbusConnection"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Declare Function ModbusNewTcp Lib "libmodbus.dll" Alias _
    "modbus_new_tcp" (ByVal ip As String, ByVal port As Long) As Long
Private Declare Function ModbusConnect Lib "libmodbus.dll" Alias _
    "modbus_connect" (ByVal ctx As Long) As Long
Private Declare Sub ModbusClose Lib "libmodbus.dll" Alias _
    "modbus_close" (ByVal ctx As Long)
Private Declare Sub ModbusFree Lib "libmodbus.dll" Alias _
    "modbus_free" (ByVal ctx As Long)
Private Declare Function ModbusSetSlave Lib "libmodbus.dll" Alias _
    "modbus_set_slave" (ByVal ctx As Long, ByVal slave As Long) As Long
Private Declare Function ModbusSetResponseTimeout Lib "libmodbus.dll" Alias _
    "modbus_set_response_timeout" (ByVal ctx As Long, ByVal sec As Long, ByVal usec As Long) As Long
Private Declare Function ModbusWriteBit Lib "libmodbus.dll" Alias _
    "modbus_write_bit" (ByVal ctx As Long, ByVal addr As Long, ByVal status As Long) As Long
Private Declare Function ModbusWriteBits Lib "libmodbus.dll" Alias _
    "modbus_write_bits" (ByVal ctx As Long, ByVal addr As Long, ByVal nb As Long, ByRef src As Byte) As Long
Private Declare Function ModbusWriteRegisters Lib "libmodbus.dll" Alias _
    "modbus_write_registers" (ByVal ctx As Long, ByVal addr As Long, ByVal nb As Long, ByRef src As Integer) As Long
Private Declare Function ModbusWriteRegister Lib "libmodbus.dll" Alias _
    "modbus_write_register" (ByVal ctx As Long, ByVal addr As Long, ByVal value As Integer) As Long
Private Declare Function ModbusReadBits Lib "libmodbus.dll" Alias _
    "modbus_read_bits" (ByVal ctx As Long, ByVal addr As Long, ByVal nb As Long, ByRef dest As Byte) As Long
Private Declare Function ModbusReadInputBits Lib "libmodbus.dll" Alias _
    "modbus_read_input_bits" (ByVal ctx As Long, ByVal addr As Long, ByVal nb As Long, ByRef dest As Byte) As Long
Private Declare Function ModbusReadRegisters Lib "libmodbus.dll" Alias _
    "modbus_read_registers" (ByVal ctx As Long, ByVal addr As Long, ByVal nb As Long, ByRef dest As Integer) As Long
Private Declare Function ModbusReadInputRegisters Lib "libmodbus.dll" Alias _
    "modbus_read_input_registers" (ByVal ctx As Long, ByVal addr As Long, ByVal nb As Long, ByRef dest As Integer) As Long

Private Const LIBMODBUS_TRUE = 1
Private Const LIBMODBUS_FALSE = 0
Private Const LIBMODBUS_ON = 1
Private Const LIBMODBUS_OFF = 0
Private Const LIBMODBUS_TCP_DEFAULT_PORT = 502
Private Const LIBMODBUS_DEFAULT_SLAVE_ID = 1

Private ctx As Long

Public Function TcpConnect( _
    ipAddress As String, _
    Optional port As Long = LIBMODBUS_TCP_DEFAULT_PORT, _
    Optional slaveId As Long = LIBMODBUS_DEFAULT_SLAVE_ID, _
    Optional responseTimeoutMillis As Long = 200) _
As Boolean
    Dim ret As Long
    Dim sec As Long
    Dim usec As Long
    
    ctx = ModbusNewTcp(ipAddress, port)
    If ctx = 0 Then
        TcpConnect = False
        Exit Function
    End If
    
    ModbusSetSlave ctx, slaveId
    
    sec = responseTimeoutMillis / 1000
    usec = (responseTimeoutMillis - (1000 * sec)) * 1000
    ModbusSetResponseTimeout ctx, sec, usec
    
    ret = ModbusConnect(ctx)
    If ret <> 0 Then
        ModbusFree ctx
        TcpConnect = False
        Exit Function
    End If
    
    TcpConnect = True
End Function

Public Sub Disconnect()
    If ctx <> 0 Then
        ModbusClose ctx
        ModbusFree ctx
    End If
End Sub

Public Function ReadBits(address As Long, numberOfBits As Long, dest() As Boolean) As Boolean
    Dim ret As Long
    Dim tmp() As Byte
    Dim i As Long
    
    ReDim tmp(UBound(dest) - LBound(dest)) As Byte
    
    ret = ModbusReadBits(ctx, address, numberOfBits, tmp(0))
    If ret <> numberOfBits Then
        ReadBits = False
        Exit Function
    End If
    
    For i = LBound(tmp) To UBound(tmp) Step 1
        If (tmp(i) = LIBMODBUS_ON) Then
            dest(i) = True
        Else
            dest(i) = False
        End If
    Next i
    
    ReadBits = True
End Function

Public Function ReadInputBits(address As Long, numberOfBits As Long, dest() As Boolean) As Boolean
    Dim ret As Long
    Dim tmp() As Byte
    Dim i As Long
    
    ReDim tmp(UBound(dest) - LBound(dest)) As Byte
    
    ret = ModbusReadInputBits(ctx, address, numberOfBits, tmp(0))
    If ret <> numberOfBits Then
        ReadInputBits = False
        Exit Function
    End If
    
    For i = LBound(tmp) To UBound(tmp) Step 1
        If (tmp(i) = LIBMODBUS_ON) Then
            dest(i) = True
        Else
            dest(i) = False
        End If
    Next i
    
    ReadInputBits = True
End Function

Public Function ReadRegisters(address As Long, numberOfRegs As Long, dest() As Integer) As Boolean
    Dim ret As Long
    
    ret = ModbusReadRegisters(ctx, address, numberOfRegs, dest(0))
    If ret <> numberOfRegs Then
        ReadRegisters = False
        Exit Function
    End If
    
    ReadRegisters = True
End Function

Public Function ReadInputRegisters(address As Long, numberOfRegs As Long, dest() As Integer) As Boolean
    Dim ret As Long
    
    ret = ModbusReadInputRegisters(ctx, address, numberOfRegs, dest(0))
    If ret <> numberOfRegs Then
        ReadInputRegisters = False
        Exit Function
    End If
    
    ReadInputRegisters = True
End Function

Public Function ReadBit(address As Long, dest As Boolean) As Boolean
    Dim tmp(0) As Boolean
    Dim ret As Long
    
    ret = ReadBits(address, 1, tmp)
    If Not ret Then
        ReadBit = False
        Exit Function
    End If
    
    dest = tmp(0)
    
    ReadBit = True
End Function

Public Function ReadInputBit(address As Long, dest As Boolean) As Boolean
    Dim tmp(0) As Boolean
    Dim ret As Long
    
    ret = ReadInputBits(address, 1, tmp)
    If Not ret Then
        ReadInputBit = False
        Exit Function
    End If
    
    dest = tmp(0)
    
    ReadInputBit = True
End Function

Public Function ReadRegister(address As Long, dest As Integer) As Boolean
    Dim tmp(0) As Integer
    Dim ret As Long
    
    ret = ReadRegisters(address, 1, tmp)
    If Not ret Then
        ReadRegister = False
        Exit Function
    End If
    
    dest = tmp(0)
    
    ReadRegister = True
End Function

Public Function ReadInputRegister(address As Long, dest As Integer) As Boolean
    Dim tmp(0) As Integer
    Dim ret As Long
    
    ret = ReadInputRegisters(address, 1, tmp)
    If Not ret Then
        ReadInputRegister = False
        Exit Function
    End If
    
    dest = tmp(0)
    
    ReadInputRegister = True
End Function

Public Function WriteBits(address As Long, numberOfBits As Long, src() As Boolean) As Boolean
    Dim ret As Long
    Dim tmp() As Byte
    Dim i As Long
    
    ReDim tmp(UBound(src) - LBound(src)) As Byte
    For i = LBound(src) To UBound(src) Step 1
        If (src(i) = True) Then
            tmp(i) = LIBMODBUS_TRUE
        Else
            tmp(i) = LIBMODBUS_FALSE
        End If
    Next i
    
    ret = ModbusWriteBits(ctx, address, numberOfBits, tmp(0))
    If ret <> numberOfBits Then
        WriteBits = False
        Exit Function
    End If
    
    WriteBits = True
End Function

Public Function WriteBit(address As Long, status As Boolean) As Boolean
    Dim tmp As Long
    Dim ret As Long
    
    If status = True Then
        tmp = LIBMODBUS_TRUE
    Else
        tmp = LIBMODBUS_FALSE
    End If
    
    ret = ModbusWriteBit(ctx, address, tmp)
    If ret <> 1 Then
        WriteBit = False
        Exit Function
    End If
    
    WriteBit = True
End Function

Public Function WriteRegisters(address As Long, numberOfRegs As Long, src() As Integer) As Boolean
    Dim ret As Long
    
    ret = ModbusWriteRegisters(ctx, address, numberOfRegs, src(0))
    If ret <> numberOfRegs Then
        WriteRegisters = False
        Exit Function
    End If
    
    WriteRegisters = True
End Function

Public Function WriteRegister(address As Long, value As Integer) As Boolean
    Dim ret As Long
    
    ret = ModbusWriteRegister(ctx, address, value)
    If ret <> 1 Then
        WriteRegister = False
        Exit Function
    End If
    
    WriteRegister = True
End Function

Private Sub Class_Initialize()
    ctx = 0
End Sub
