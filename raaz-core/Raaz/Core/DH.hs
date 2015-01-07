-- | This module provides an abstract interface for Diffie Hellman Key Exchange.

{-# LANGUAGE TypeFamilies               #-}

module Raaz.Core.DH
       ( DH(..) ) where

-- | The DH (Diffie-Hellman) typeclass provides an interface for key
--  exchanges. 'Secret' represents the secret generated by each party
--  & known only to itself. 'PublicToken' represents the token
--  generated from the 'Secret' which is sent to the other party.
-- 'SharedSecret' represents the common secret generated by both
--  parties from the respective public tokens. 'publicToken' takes the
--  generator of the group and a secret and generates the public token.
-- 'sharedSecret' takes the generator of the group, secret of one party
--  and public token of the other party and generates the shared secret.
class DH d where
  type Secret d       :: *
  type PublicToken d  :: *
  type SharedSecret d :: *

  publicToken   :: d -> Secret d -> PublicToken d
  sharedSecret  :: d -> Secret d -> PublicToken d -> SharedSecret d