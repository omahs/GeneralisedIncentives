//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

// IncentivizedMessageEscrow Payload***********************************************************************************************
//
// Common Payload (beginning)
//    CONTEXT                           0   (1 byte)
//    + MESSAGE_IDENTIFIER              1   (32 bytes)
//    + FROM_APPLICATION_LENGTH         33  (1 byte)
//    + FROM_APPLICATION                34  (64 bytes)
// 
// Context-depending Payload
//    CTX0 - 0x00 - Source to Destination
//      + TO_VAULT_LENGTH               98  (1 byte)
//      + TO_VAULT                      99  (64 bytes)
//      + MIN_GAS                       163 (8 bytes)
//     => MESSAGE_START                 171 (remainder)
//
//    CTX1 - 0x01 - Destination to Source
//      + RELAYER_RECIPITENT_LENGTH     98  (1 byte)
//      + RELAYER_RECIPITENT            99  (64 bytes)
//      + GAS_SPENT                     163 (16 bytes)
//      + EXECUTION_TIME                179 (8 bytes)
//     => MESSAGE_START                 187 (remainder)


// Contexts *********************************************************************************************************************

bytes1 constant SourcetoDestination     = 0x00;
bytes1 constant DestinationtoSource     = 0x01;


// Common Payload ***************************************************************************************************************

uint constant CONTEXT_POS                       = 0;

uint constant MESSAGE_IDENTIFIER_START          = 1;
uint constant MESSAGE_IDENTIFIER_END            = 33;

uint constant FROM_APPLICATION_LENGTH_POS       = 33;
uint constant FROM_APPLICATION_START            = 34;
uint constant FROM_APPLICATION_START_EVM        = 78;  // If the address is an EVM address, this is the start
uint constant FROM_APPLICATION_END              = 98;


// CTX0 Source to Destination ******************************************************************************************************

uint constant CTX0_TO_APPLICATION_LENGTH_POS        = 98;
uint constant CTX0_TO_APPLICATION_START             = 99;
uint constant CTX0_TO_APPLICATION_START_EVM         = 143;  // If the address is an EVM address, this is the start
uint constant CTX0_TO_APPLICATION_END               = 163;

uint constant CTX0_MIN_GAS_LIMIT_START              = 163;
uint constant CTX0_MIN_GAS_LIMIT_END                = 171;

uint constant CTX0_MESSAGE_START                    = 171;

// CTX1 Destination to Source **************************************************************************************************

uint constant CTX1_RELAYER_RECIPITENT_LENGTH_POS    = 98; 
uint constant CTX1_RELAYER_RECIPITENT_START         = 99; 
uint constant CTX1_RELAYER_RECIPITENT_START_EVM     = 143;  // If the address is an EVM address, this is the start
uint constant CTX1_RELAYER_RECIPITENT_END           = 163;

uint constant CTX1_GAS_SPENT_START                  = 163;
uint constant CTX1_GAS_SPENT_END                    = 179;

uint constant CTX1_EXECUTION_TIME_START             = 179;
uint constant CTX1_EXECUTION_TIME_END               = 187;

uint constant CTX1_MESSAGE_START                    = 187;