{-# LANGUAGE ForeignFunctionInterface  #-}
{-# LANGUAGE FlexibleInstances         #-}
{-# LANGUAGE FlexibleContexts          #-}
{-# LANGUAGE MultiParamTypeClasses     #-}
{-# LANGUAGE TypeFamilies              #-}
{-# OPTIONS_GHC -fno-warn-orphans      #-}
{-# CFILES raaz/cipher/cportable/aes.c #-}

module Raaz.Cipher.AES.CBC.CPortable () where

import Foreign.Storable         (sizeOf,Storable)

import Raaz.Memory
import Raaz.Primitives
import Raaz.Primitives.Cipher
import Raaz.Types
import Raaz.Util.Ptr            (allocaBuffer)

import Raaz.Cipher.AES.CBC.Type
import Raaz.Cipher.AES.Internal

foreign import ccall unsafe
  "raaz/cipher/cportable/aes.c raazCipherAESCBCEncrypt"
  c_cbc_encrypt  :: CryptoPtr  -- ^ expanded key
                 -> CryptoPtr  -- ^ Input
                 -> CryptoPtr  -- ^ IV
                 -> Int        -- ^ Number of Blocks
                 -> Int        -- ^ Key type
                 -> IO ()

foreign import ccall unsafe
  "raaz/cipher/cportable/aes.c raazCipherAESCBCDecrypt"
  c_cbc_decrypt  :: CryptoPtr  -- ^ expanded key
                 -> CryptoPtr  -- ^ Input
                 -> CryptoPtr  -- ^ IV
                 -> Int        -- ^ Number of Blocks
                 -> Int        -- ^ Key type
                 -> IO ()

instance Gadget (CGadget (Cipher AES KEY128 CBC Encryption)) where
  type PrimitiveOf (CGadget (Cipher AES KEY128 CBC Encryption)) = Cipher AES KEY128 CBC Encryption
  type MemoryOf (CGadget (Cipher AES KEY128 CBC Encryption)) = (CryptoCell Expanded128, CryptoCell STATE)
  newGadgetWithMemory = return . CGadget
  initialize (CGadget (ek,s)) (AESIV (k,iv)) = do
    withCell s (flip store iv)
    cExpand128 k ek
  finalize _ = return Cipher
  apply = loadAndApply c_cbc_encrypt 0

instance Gadget (CGadget (Cipher AES KEY128 CBC Decryption)) where
  type PrimitiveOf (CGadget (Cipher AES KEY128 CBC Decryption)) = Cipher AES KEY128 CBC Decryption
  type MemoryOf (CGadget (Cipher AES KEY128 CBC Decryption)) = (CryptoCell Expanded128, CryptoCell STATE)
  newGadgetWithMemory = return . CGadget
  initialize (CGadget (ek,s)) (AESIV (k,iv)) = do
    withCell s (flip store iv)
    cExpand128 k ek
  finalize _ = return Cipher
  apply = loadAndApply c_cbc_decrypt 0

instance Gadget (CGadget (Cipher AES KEY192 CBC Encryption)) where
  type PrimitiveOf (CGadget (Cipher AES KEY192 CBC Encryption)) = Cipher AES KEY192 CBC Encryption
  type MemoryOf (CGadget (Cipher AES KEY192 CBC Encryption)) = (CryptoCell Expanded192, CryptoCell STATE)
  newGadgetWithMemory = return . CGadget
  initialize (CGadget (ek,s)) (AESIV (k,iv)) = do
    withCell s (flip store iv)
    cExpand192 k ek
  finalize _ = return Cipher
  apply = loadAndApply c_cbc_encrypt 1

instance Gadget (CGadget (Cipher AES KEY192 CBC Decryption)) where
  type PrimitiveOf (CGadget (Cipher AES KEY192 CBC Decryption)) = Cipher AES KEY192 CBC Decryption
  type MemoryOf (CGadget (Cipher AES KEY192 CBC Decryption)) = (CryptoCell Expanded192, CryptoCell STATE)
  newGadgetWithMemory = return . CGadget
  initialize (CGadget (ek,s)) (AESIV (k,iv)) = do
    withCell s (flip store iv)
    cExpand192 k ek
  finalize _ = return Cipher
  apply = loadAndApply c_cbc_decrypt 1

instance Gadget (CGadget (Cipher AES KEY256 CBC Encryption)) where
  type PrimitiveOf (CGadget (Cipher AES KEY256 CBC Encryption)) = Cipher AES KEY256 CBC Encryption
  type MemoryOf (CGadget (Cipher AES KEY256 CBC Encryption)) = (CryptoCell Expanded256, CryptoCell STATE)
  newGadgetWithMemory = return . CGadget
  initialize (CGadget (ek,s)) (AESIV (k,iv)) = do
    withCell s (flip store iv)
    cExpand256 k ek
  finalize _ = return Cipher
  apply = loadAndApply c_cbc_encrypt 2

instance Gadget (CGadget (Cipher AES KEY256 CBC Decryption)) where
  type PrimitiveOf (CGadget (Cipher AES KEY256 CBC Decryption)) = Cipher AES KEY256 CBC Decryption
  type MemoryOf (CGadget (Cipher AES KEY256 CBC Decryption)) = (CryptoCell Expanded256, CryptoCell STATE)
  newGadgetWithMemory = return . CGadget
  initialize (CGadget (ek,s)) (AESIV (k,iv)) = do
    withCell s (flip store iv)
    cExpand256 k ek
  finalize _ = return Cipher
  apply = loadAndApply c_cbc_decrypt 2

loadAndApply encrypt i (CGadget (ek,civ)) n cptr = withCell ek (withCell civ . doStuff)
    where
      doStuff ekptr ivptr = encrypt ekptr cptr ivptr (fromIntegral n) i
{-# INLINE loadAndApply #-}