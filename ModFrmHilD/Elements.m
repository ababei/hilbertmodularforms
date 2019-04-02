/*****
ModFrmHilDElt
*****/

////////// ModFrmHilDElt attributes //////////

declare type ModFrmHilDElt;
declare attributes ModFrmHilDElt:
  Parent, // ModFrmHilD
  Weight, // SeqEnum[RngIntElt]
  Level, // RngOrdIdl
  Coefficients, // Coefficients[bb] = coeffs_bb where coeffs_bb[nu] = a_(bb,nu) = a_(nu)*bb^-1
  CoefficientsParents; // CoefficientsParents[bb] = Parent of coefficients for Coefficients[bb]

////////// ModFrmHilDElt fundamental intrinsics //////////

// TODO: narrow>1
intrinsic PercentM(f::ModFrmHilDElt) -> MonStgElt
  {returns a string to produce f in a magma session.}
  return Sprintf("HMF(%m, %m, %m)", Parent(f), Weight(f), Coefficients(f));
end intrinsic;

//By Norm 
intrinsic Print(f::ModFrmHilDElt, level::MonStgElt : num_coeffs := 10)
  {}
  if level in ["Default", "Minimal", "Maximal"] then
    M := Parent(f);
    bbs := NarrowClassGroupReps(M);
    k := Weight(f);
    prec := Precision(f);
    coeffs := Coefficients(f);
    N := Level(f);
    printf "Hilbert modular form expansion with precision %o.\n", prec;
    printf "Level: (Norm, Ideal) = (%o, %o)\n", Norm(N),  Generators(N);
    printf "Weight: %o\n", k;
    printf "Parent: %o\n", M;
    for bb in bbs do
      coeffs_bb := coeffs[bb];
      printf "Coefficients for ideal class bb = %o\n", bb;
      printf "\n\t(Ideal)  |--->   a_nn = a_(nu)*bb^-1";
      for nn in IdealsByNarrowClassGroup(M)[bb] do
        printf "\n\t(%o)  |--->   %o", IdealOneLine(nn), coeffs_bb[nn];
      end for;
      printf "\n\n";
    end for;
  elif level eq "Magma" then
    printf "%o", PercentM(f);
  else
    error "not a valid printing level.";
  end if;
end intrinsic;

/*
//By Trace
intrinsic Print(f::ModFrmHilDElt, level::MonStgElt : num_coeffs := 10)
  {}
  if level in ["Default", "Minimal", "Maximal"] then
    M := Parent(f);
    bbs := NarrowClassGroupReps(M);
    k := Weight(f);
    prec := Precision(f);
    coeffs := Coefficients(f);
    N := Level(f);
    printf "Hilbert modular form expansion with precision %o.\n", prec;
    printf "Level: (Norm, Ideal) = (%o, %o)\n", Norm(N),  Generators(N);
    printf "Weight: %o\n", k;
    printf "Parent: %o\n", M;
    for bb in bbs do
      coeffs_bb := coeffs[bb];
      printf "Coefficients for ideal class bb = %o\n", bb;
      printf "\n\t(Trace, nu)  |--->   a_nu = a_(nu)*bb^-1";
      for t in Keys(ShintaniReps(M)[bb]) do
        for nu in ShintaniReps(M)[bb][t] do
          assert Trace(nu) eq t;
          printf "\n\t(%o, %o)  |--->   %o", t,  nu, coeffs_bb[nu];
        end for;
      end for;
      printf "\n\n";
    end for;
  elif level eq "Magma" then
    printf "%o", PercentM(f);
  else
    error "not a valid printing level.";
  end if;
end intrinsic;

*/

////////// ModFrmHilDElt access to attributes //////////

intrinsic Parent(f::ModFrmHilDElt) -> ModFrmHilD
  {returns ModFrmHilD space where f lives.}
  return f`Parent;
end intrinsic;

intrinsic Weight(f::ModFrmHilDElt) -> SeqEnum[RngIntElt]
  {returns weight of f.}
  return f`Weight;
end intrinsic;

intrinsic BaseField(f::ModFrmHilDElt) -> FldNum
  {returns base field of parent of f.}
  return BaseField(Parent(f));
end intrinsic;

intrinsic Level(f::ModFrmHilDElt) -> RngOrdIdl
  {returns level of parent of f.}
  return f`Level;
end intrinsic;

intrinsic Precision(f::ModFrmHilDElt) -> RngIntElt
  {returns precision of parent of f.}
  return Precision(Parent(f));
end intrinsic;

intrinsic Coefficients(f::ModFrmHilDElt) -> Any
  {}
  return f`Coefficients;
end intrinsic;

intrinsic CoefficientsParents(f::ModFrmHilDElt) -> Any
  {}
  return f`CoefficientsParents;
end intrinsic;

intrinsic CoefficientsParent(f::ModFrmHilDElt) -> Any
  {}
  M := Parent(f);
  coeffs := Coefficients(f); // indexed by bb
  bbs := NarrowClassGroupReps(M);
  return Parent(coeffs[bbs[1]][1]);
end intrinsic;

////////// ModFrmHilDElt creation functions //////////

intrinsic ModFrmHilDEltInitialize() -> ModFrmHilDElt
  {Create an empty ModFrmHilDElt object.}
  f := New(ModFrmHilDElt);
  return f;
end intrinsic;

intrinsic ModFrmHilDEltCopy(f::ModFrmHilDElt) -> ModFrmHilDElt
  {new instance of ModFrmHilDElt.}
  g := ModFrmHilDEltInitialize();
  for attr in GetAttributes(Type(f)) do
    if assigned f``attr then
      g``attr := f``attr;
    end if;
  end for;
  return g;
end intrinsic;

intrinsic HMF(M::ModFrmHilD, N::RngOrdIdl, k::SeqEnum[RngIntElt], coeffs::Assoc) -> ModFrmHilDElt
  {WARNING: user is responsible for coefficients besides some basic structural assertions. Note: coeffs[bb][nu] = a_(bb, nu) = a_(nu)*(bb)^-1}
  // check coeffs[bb] defined for each ideal class bb
  if #Keys(coeffs) ne #NarrowClassGroupReps(M) then
    error "Associative array of coefficients should be indexed by ideal classes";
  end if;
  
  bbs := NarrowClassGroupReps(M);
  coeff_parents := AssociativeArray();
  for bb in bbs do
    // check coeffs[bb] has keys equal IdealsByNarrowClassGroup(M)[bb]
    assert Set(IdealsByNarrowClassGroup(M)[bb]) eq Keys(coeffs[bb]);
    // check coeffs[bb][n] has a value for every n in IdealsByNarrowClassGroup(M)[bb]
    for nn in IdealsByNarrowClassGroup(M)[bb] do
      assert IsDefined(coeffs[bb], nn);
    end for;
    key := Random(Keys(coeffs[bb]));
    coeff_parents[bb] := Parent(coeffs[bb][key]);
  end for;
  
  // make the HMF
  f := ModFrmHilDEltInitialize();
  f`Parent := M;
  f`Weight := k;
  f`Level := N;
  f`Coefficients := coeffs;
  f`CoefficientsParents := coeff_parents;
  return f;
end intrinsic;

intrinsic HMFZero(M::ModFrmHilD, N::RngOrdIdl, k::SeqEnum[RngIntElt]) -> ModFrmHilDElt
  {create zero ModHilFrmDElt of weight k.}
  coeffs := AssociativeArray();
  for bb in NarrowClassGroupReps(M) do
    coeffs_bb := AssociativeArray();
    for nu in IdealsByNarrowClassGroup(M)[bb] do
      coeffs_bb[nu] := 0;
    end for;
    coeffs[bb] := coeffs_bb;
  end for;
  return HMF(M, N, k, coeffs);
end intrinsic;

////////// ModFrmHilDElt accessing and setting coefficients //////////

/* intrinsic GetCoefficient(f::ModFrmHilDElt, I::RngOrdIdl) -> RngElt */
/*   {returns a_I} */
/*   return Coefficients(f)[Dictionary(f)[I]]; */
/* end intrinsic; */

/* intrinsic SetCoefficient(f::ModFrmHilDElt, I::RngOrdIdl, c::RngElt) */
/*   {sets a_I to c} */
/*   f`Coefficients[Dictionary(f)[I]] := c; */
/* end intrinsic; */

/* intrinsic GetCoefficient(f::ModFrmHilDElt, nu::RngOrdElt) -> RngElt */
/*   {returns a_nu} */
/*   if not assigned Parent(f)`Representatives then */
/*     error "You must first equip the space with a multiplication table"; */
/*   end if; */
/*   return Coefficients(f)[DictionaryRepresentatives(f)[nu]]; */
/* end intrinsic; */

/* intrinsic SetCoefficient(f::ModFrmHilDElt, nu::RngOrdElt, c::RngElt) */
/*   {sets a_nu to c} */
/*   if not assigned Parent(f)`Representatives then */
/*     error "You must first equip the space with a multiplication table"; */
/*   end if; */
/*   f`Coefficients[DictionaryRepresentatives(f)[nu]] := c; */
/* end intrinsic; */

/* intrinsic GetCoefficientsIdeal(f::ModFrmHilDElt) -> Assoc */
/*   {given a ModFrmHilDElt, return associative array of coefficients on the ideals.} */
/*   coeffs := Coefficients(f); */
/*   ideals := Ideals(f); */
/*   result := AssociativeArray(); */
/*   for i := 1 to #ideals do */
/*     result[ideals[i]] := coeffs[i]; */
/*   end for; */
/*   return result; */
/* end intrinsic; */

/* intrinsic GetCoefficientsRepresentatives(f::ModFrmHilDElt) -> Assoc */
/*   {given a ModFrmHilDElt, return associative array of coefficients on the representatives.} */
/*   if not assigned Parent(f)`Representatives then */
/*     error "You must first equip the space with a multiplication table"; */
/*   end if; */
/*   coeffs := Coefficients(f); */
/*   reps := Representatives(f); */
/*   result := AssociativeArray(); */
/*   for i := 1 to #reps do */
/*     result[reps[i]] := coeffs[i]; */
/*   end for; */
/*   return result; */
/* end intrinsic; */


////////////// ModFrmHilDElt: Coercion /////////////////////////


// Coerces HMF coefficients a_n in a ring R
intrinsic '!'(R::Rng, f::ModFrmHilDElt) -> ModFrmHilDElt
  {returns f such that a_I := R!a_I}
  M := Parent(f);
  bbs := NarrowClassGroupReps(M);
  coeffs := Coefficients(f);
  new_coeffs := AssociativeArray();
  for bb in bbs do
    for nn in Keys(coeffs[bb]) do
      new_coeffs[bb][nn] := R!coeffs[bb][nn];
    end for;
  end for;
  return HMF(Parent(f), Level(f), Weight(f), new_coeffs);
end intrinsic;

//FIXME NarrowClassNumber >1 - Ben
intrinsic IsCoercible(M::ModFrmHilD, f::.) -> BoolElt, .
  {}
  if ISA(Type(f), RngElt) then
    P := Parent(f);
    N := 1*Integers(M); // FIXME only level 1 for now
    coeffs := [P!0 : c in [1..#Ideals(M)]];
    coeffs[1] := f;
    k := [0 : c in [1..Degree(BaseField(M))]];
    return true, HMF(M, N, k, coeffs);
  end if;

  if Type(f) ne ModFrmHilDElt then
    return false;
  end if;

  if Parent(f) eq M then
    return true, f;
  elif (BaseField(M) eq BaseField(f)) and (Precision(M) eq Precision(f)) then
    coeffs := Coefficients(f);
    return true, HMF(M, Level(f), Weight(f) , coeffs);
  else
    return false;
  end if;
end intrinsic;

/*
intrinsic '!'(M::ModFrmHilD, f::ModFrmHilDElt) -> ModFrmHilDElt
  {returns f with parent M}
  nn := Level(M);
  nnf := Level(f);
  assert nn subset nnf; // nnf divides nn
  coeffs := Coefficients(f);
  return HMF(M, Weight(f) , coeffs);
end intrinsic;
*/

intrinsic 'in'(x::., y::ModFrmHilDElt) -> BoolElt
  {}
  return false;
end intrinsic;

intrinsic IsCoercible(x::ModFrmHilDElt, y::.) -> BoolElt, .
  {}
  return false;
end intrinsic;

//////////  ModFrmHilDElt: Galois action on Coefficients ////////// 

//TODO:
//Tests:
// - Apply Hecke on a Galois Orbit, and see that it doesn't move
// - Apply Hecke to a Eisensten series, and check that is a multiple
// - Apply Hecke to a Theta series, and see if we get the whole space


intrinsic GaloisOrbit(f::ModFrmHilDElt) -> SeqEnum[ModFrmHilDElt] 
  {returns the full Galois orbit of a modular form} 
  M := Parent(f); 
  k := Weight(f); 
  K := NumberField(CoefficientsParent(f)); 
  G, Pmap, Gmap := AutomorphismGroup(K); 
  bbs := NarrowClassGroupReps(M);
  result := []; 
  for g in G do 
    coeff := Coefficients(f); 
    for bb in bbs do
      for nn in Keys(Coefficients(f)[bb]) do
        coeff[bb][nn] := Gmap(g)(coeff[bb][nn]);
      end for;
    end for;
    Append(~result, HMF(M, Level(f), k, coeff)); 
  end for; 
  return result; 
end intrinsic; 

// TODO: narrow>1
intrinsic GaloisOrbitDescent(f::ModFrmHilDElt) -> SeqEnum[ModFrmHilDElt] 
  {returns the full Galois orbit of a modular form over Q} 
  M := Parent(f); 
  k := Weight(f); 
  result := [];
  bbs := NarrowClassGroupReps(M);
  for bb in bbs do
    coeff := Coefficients(f);
    for nn in Keys(Coefficients(f)[bb]) do
      coeff[bb][nn] := Trace(b * coeff[bb][nn]);
    end for;
    Append(~result, HMF(M, Level(f), k, coeff)); 
  end for;
  return result; 
end intrinsic; 


///////////// ModFrmHilDElt: Hecke Operators ////////////////


// TODO: narrow>1
/* intrinsic HeckeOperator(f::ModFrmHilDElt, nn::RngOrdIdl : Basis:=[]) -> ModFrmHilDElt */
/*   {returns T(n)(f) for the trivial character} */
/*   return HeckeOperator(f, nn, HeckeCharacterGroup(Level(f))! 1 : Basis:=Basis); */
/* end intrinsic; */


// TODO: narrow>1
/* intrinsic HeckeOperator(f::ModFrmHilDElt, nn::RngOrdIdl, chi::GrpHeckeElt : Basis:= []) -> ModFrmHilDElt */
/*   {returns T(n)(f) with loss of precision. If a basis for the space is provided, returns T(n)(f) without loss of precision} */
/*   M := Parent(f); */
/*   fcoeffs := Coefficients(f); */
/*   ideals := Ideals(f); */
/*   dict := Dictionary(f); */
/*   ZC := Parent(fcoeffs[1]); */
/*   k0 := Max(Weight(f)); */
/*   prec:=Precision(M); */
/*   //We work in smaller precision and obtain a function the space of precision Prec/Norm(nn) */
/*   idealssmallprec:=[ideals[1]]; */
/*   for x:=2 to #ideals do */
/*     if Norm(ideals[x]) le prec/Norm(nn) then */
/*       idealssmallprec:= idealssmallprec cat [ideals[x]]; */
/*     end if; */
/*   end for; */
/*   coeffssmallprec := [ZC!0 : i in [1..#idealssmallprec]]; */
/*   for i:=1 to #idealssmallprec do */
/*     c := 0; */
/*     // loop over divisors */
/*     // Formula 2.23 in Shimura - The Special Values of the zeta functions associated with Hilbert Modular Forms */
/*     for aa in Divisors(ideals[i] + nn) do */
/*       c +:= chi(aa) * Norm(aa)^(k0 - 1) * fcoeffs[ dict[ aa^(-2) * (ideals[i] * nn)]]; */
/*       end for; */
/*     coeffssmallprec[i] := c; */
/*     end for; */
/*   if #Basis ne 0 then //if provided a basis, we reconstruct the form to the same precision */
/*     smallprecbasis:=[]; */
/*     for g in Basis do */
/*       Append(~smallprecbasis, [Coefficients(g)[i] : i in [1..#idealssmallprec]]); */
/*     end for; */
/*     LinComb:=LinearDependence([coeffssmallprec] cat smallprecbasis); */
/*     if ISA(Type(LinComb), RngIntElt) or #Rows(LinComb) ne 1 then */
/*       return "Error: either precision is too small, or the sequence provided is not a basis"; */
/*     end if; */
/*     g:=0*f; */
/*     for i:=2 to #Basis+1 do */
/*       g:=g-LinComb[1][i]*Basis[i-1]; */
/*     end for; */
/*     return g; */
/*   end if; */
/*   if #Basis eq 0 then */
/*     M1:=HMFSpace(BaseField(M), Floor(prec/Norm(nn))); */
/*     print "Warning: the Hecke operator calculation decreases precision to ", */
/*     Floor(prec/Norm(nn)); */
/*     return HMF(M1, Level(f), Weight(f), coeffssmallprec); */
/*   end if; */
/* end intrinsic; */

////////// ModFrmHilDElt: Arithmetic //////////

//TODO make zero HMF universal so it can be added/multiplied to any HMF

intrinsic 'eq'(f::ModFrmHilDElt, g::ModFrmHilDElt) -> BoolElt
  {compares Parent, Weight, and Coefficients.}
  M := Parent(f);
  if Parent(f) ne Parent(g) then
    return false;
  end if;
  if Weight(f) ne Weight(g) then
    return false;
  end if;
  bbs := NarrowClassGroupReps(M);
  for bb in bbs do
    assert Keys(Coefficients(f)) eq Keys(Coefficients(g));
    for nn in Coefficients(f) do
      if Coefficients(f)[bb][nn] ne Coefficients(g)[bb][nn] then
        return false;
      end if;
    end for;
  end for;
  return true;
end intrinsic;


intrinsic '*'(c::RngIntElt, f::ModFrmHilDElt) -> ModFrmHilDElt
  {scale f by integer c.}
  N := Level(f);
  M := Parent(f);
  k := Weight(f);
  coeffs := Coefficients(f);
  bbs := NarrowClassGroupReps(M);
  for bb in bbs do 
    ZK := CoefficientsParents(f)[bb];
    print ZK;
    assert c in ZK;
    for nn in Keys(Coefficients(f)[bb]) do
      coeffs[bb][nn] := ZK!(c * Coefficients(f)[bb][nn]);
    end for;
  end for;
  return HMF(M, N, k, coeffs);
end intrinsic;


intrinsic '*'(c::Any, f::ModFrmHilDElt) -> ModFrmHilDElt
  {scale f by some scalar c.}
  N := Level(f);
  M := Parent(f);
  k := Weight(f);
  coeffs := Coefficients(f);
  bbs := NarrowClassGroupReps(M);
  for bb in bbs do 
    F := FieldOfFractions(CoefficientsParents(f)[bb]);
    assert c in F;
    for nn in Keys(Coefficients(f)[bb]) do
      coeffs[bb][nn] := F!(c * Coefficients(f)[bb][nn]);
    end for;
  end for;
  return HMF(M, N, k, coeffs);
end intrinsic;


intrinsic '+'(f::ModFrmHilDElt, g::ModFrmHilDElt) -> ModFrmHilDElt
  {return f+g.}
  // Currently returns the lowest precision of the forms 
  // assert Parent(f) eq Parent(g);
  assert Level(f) eq Level(g);
  assert Weight(f) eq Weight(g);
  N := Level(f) meet Level(g);
  M := Parent(f);
  k := Weight(f);
  new_coeffs := AssociativeArray();
  bbs := NarrowClassGroupReps(M);
  for bb in bbs do
    new_coeffs[bb] := AssociativeArray();
    assert CoefficientsParents(f)[bb] eq CoefficientsParents(g)[bb];
    New_keys := Keys(Coefficients(f)[bb]) meet Keys(Coefficients(g)[bb]); // Adding drops the precision to the intersection of the precision of the forms
    for nn in New_keys do
      new_coeffs[bb][nn] := Coefficients(f)[bb][nn] + Coefficients(g)[bb][nn];
    end for;
  end for;
  return HMF(M, N, k, new_coeffs);
end intrinsic;

intrinsic '-'(f::ModFrmHilDElt, g::ModFrmHilDElt) -> ModFrmHilDElt
  {return f-g.}
  return f + (-1)*g;
end intrinsic;

// TODO only works when k has even weight
// TODO for varied precision
intrinsic '*'(f::ModFrmHilDElt, g::ModFrmHilDElt) -> ModFrmHilDElt
  {return f*g}
  N := Level(f) meet Level(g);
  M := Parent(f);
  k := [ Weight(g)[i] + Weight(f)[i] : i in [1..#Weight(g)] ];

  assert Parent(f) eq Parent(g);
  MTable := MultiplicationTables(M);
  bbs := NarrowClassGroupReps(M);
  new_coeff := AssociativeArray();
  for bb in bbs do
    new_coeff[bb] := AssociativeArray();
    ZF := CoefficientsParents(f)[bb];
    assert ZF eq CoefficientsParents(g)[bb];
    for nn in Keys(Coefficients(f)[bb]) do
      c := ZF!0;
      for pair in MTable[bb][nn] do
        c +:= Coefficients(f)[bb][ pair[1] ] * Coefficients(g)[bb][ pair[2] ];
      end for;
      new_coeff[bb][nn] := c;
    end for;
  end for;
  return HMF(M, N, k, new_coeff);
end intrinsic;


// TODO FIXME Cl^+(F)>1
intrinsic '/'(f::ModFrmHilDElt, g::ModFrmHilDElt) -> ModFrmHilDElt
  {return f/g}
  N := Level(f) meet Level(g);
  M := Parent(f);
  assert Parent(f) eq Parent(g);
  if not assigned M`MultiplicationTable then
    assert HMFEquipWithMultiplication(M);
  end if;
  prec := Precision(M);
  fcoeffs := Coefficients(f);
  gcoeffs := Coefficients(g);
  // TODO make it work if Valuation(g) <= Valuation(f)
  require gcoeffs[1] ne 0: "Denominator must have nonzero constant term";
  ib0 := 1/gcoeffs[1];
  ZC := CoefficientsParent(f);
  MTable := MultiplicationTable(M);
  assert ZC eq CoefficientsParent(g);
  coeffs := [ZC!0 :  i in [1..#fcoeffs]];
  for i := 1 to #fcoeffs do
    c := fcoeffs[i];
    for pair in MTable[i] do
      if pair[1] ne 1 then
        c -:= gcoeffs[ pair[1] ] * coeffs[ pair[2] ];
      else
        assert pair[2] eq i;
      end if;
    end for;
    coeffs[i] := c * ib0;
  end for;
  kf := Weight(f);
  kg := Weight(g);
  k := [ kf[i] - kg[i] : i in [1..#kf] ];
  return HMF(M, N, k, coeffs);
end intrinsic;

// TODO FIXME Cl^+(F)>1
intrinsic Inverse(f::ModFrmHilDElt) -> ModFrmHilDElt
  {return 1/f}
  return (Parent(f) ! ( CoefficientsParent(f) ! 1) ) / f;
end intrinsic;

intrinsic '^'(f::ModFrmHilDElt, n::RngIntElt) -> ModFrmHilDElt
  {return f^e}
  if n lt 0 then
    f := Inverse(f);
  end if;
  g := Parent(f) ! (CoefficientsParent(f) ! 1);
  if n eq 0 then
    return g;
  end if;
  while n gt 1 do
    if n mod 2 eq 0 then
      f := f * f;
      n := Integers() ! (n/2);
    else
      g := f * g;
      f := f * f;
      n := Integers() ! ((n - 1)/2);
    end if;
  end while;
  return f * g;
end intrinsic;


////////// ModFrmHilDElt: Linear Algebra  //////////

//TODO add optional flag to limit the number of coefficients
intrinsic CoefficientsMatrix(list::SeqEnum[ModFrmHilDElt]) -> AlgMatElt
  {returns a matrix with the coefficients of each modular form in each row}
  return Matrix( [ Coefficients(elt) : elt in list] );
end intrinsic;



intrinsic LinearDependence(list::SeqEnum[SeqEnum] ) -> SeqEnum[RngIntElt]
  {finds a small non-trivial integral linear combination between components of v. If none can be found return 0.}
  M := Matrix( [ elt : elt in list] );
  B := Basis(Kernel(M));
  if #B ne 0 then
    Mat := Matrix(LLL(Basis(Kernel(M))));
    return [Eltseq(i) : i in Rows(Mat)];
  else
    return [];
  end if;
end intrinsic;

//TODO add optional flag to limit the number of coefficients
//TODO make outputs to be of the same type

intrinsic LinearDependence(list::SeqEnum[ModFrmHilDElt] ) -> SeqEnum[RngIntElt]
  {finds a small non-trivial integral linear combination between components of v. If none can be found return 0.}
  return LinearDependence([ Coefficients(elt) : elt in list] );
end intrinsic;

//EchelonBasis


////////// ModFrmHilDElt: swap map //////////

/* intrinsic Swap(f::ModFrmHilDElt) -> ModFrmHilDElt */
/*   {given a hilbert modular form f(z_1, z_2), returns the swapped form f(z_2,z_1)} */
/*   M:=Parent(f); */
/*   g:=M!(1*f); */
/*   F:=BaseField(M); */
/*   ZF<w>:=Integers(F); */
/*   ideals:=Ideals(f); */
/*   for i in ideals do */
/*     x:=GetCoefficient(f, Conjugate(i)); */
/*     SetCoefficient(g, i, x); */
/*   end for; */
/*   return g; */
/* end intrinsic; */
