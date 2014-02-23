-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Flycheck.PrintCabal where

import Distribution.Verbosity (silent)
import Distribution.PackageDescription (PackageDescription
                                       ,allBuildInfo
                                       ,hsSourceDirs
                                       ,testBuildInfo
                                       ,testSuites)
import Distribution.PackageDescription.Configuration (flattenPackageDescription)
import Distribution.PackageDescription.Parse (readPackageDescription)
import System.Environment (getArgs)
import System.Exit (exitFailure)
import Control.Monad (liftM2)
import Data.List (nub)

collectSourceDirectories :: PackageDescription -> [FilePath]
collectSourceDirectories = nub . concatMap hsSourceDirs . liftM2 (++)  allBuildInfo
                                                      (fmap testBuildInfo . testSuites)


getSourceDirectories :: FilePath -> IO [FilePath]
getSourceDirectories cabalFile = do
  desc <- readPackageDescription silent cabalFile
  return (collectSourceDirectories (flattenPackageDescription desc))


main :: IO ()
main = do
  args <- getArgs
  case args of
    [filename] -> getSourceDirectories filename >>= mapM_ putStrLn
    _ -> exitFailure
