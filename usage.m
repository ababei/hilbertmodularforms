/*****
examples using ModFrmHilD, ModFrmHilDElt
*****/

// load configuration, spec file, printing, etc.
load "config.m";

// basic inputs to creation functions
F := QuadraticField(8);
ZF<w> := Integers(F);
N := ideal<ZF | { 3}>;
k := [2, 2];
K := Rationals();
prec := 100;
max_prec := 200;

// ModFrmHilD creation and access to attributes
M := HMFSpace(F, N, max_prec);
BaseField(M); // F
Level(M); // N
MaxPrecision(M); // max_prec
Ideals(M); // ideals of ZF (including 0) up to norm max_prec
Dictionary(M); // internal

// ModFrmHilDElt can be made by providing space and coefficients

// http://www.lmfdb.org/L/EllipticCurve/2.2.8.1/9.1/a/
MF := HilbertCuspForms(F, N);
S := NewSubspace(MF);
newspaces := NewformDecomposition(S);
newforms := [Eigenform(U) : U in newspaces];
eigenvalues := AssociativeArray();
primes := PrimesUpTo(prec, F);
for pp in primes do
    eigenvalues[pp] := HeckeEigenvalue(newforms[1],pp);
end for;

ef := EigenformToHMF(M, k, eigenvalues, prec);
print ef;
// Compare with http://www.lmfdb.org/L/EllipticCurve/2.2.8.1/9.1/a/
// a_n = \sum a_nn where Norm(nn) = n

// basic inputs to creation functions
F := QuadraticField(5);
ZF<w> := Integers(F);
N := ideal<ZF | {10}>;
k := [2, 2];
K := Rationals();
prec := 100;
M := HMFSpace(F, N, k, K);
efs := NewformsToHMF(M, k, prec);
assert #efs eq 2;




