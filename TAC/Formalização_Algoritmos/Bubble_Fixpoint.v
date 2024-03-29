(* 116297 - Tópicos Avançados em Computadores *)
(* Provas Formais: Uma Introdução à Teoria de Tipos - Turma B *)
(* Prof. Flávio L.C. de Moura *)
(* Email: contato@flaviomoura.mat.br *)
(* Homepage: http://flaviomoura.mat.br *)

(* Aluno: Raphael Soares Ramos *)
(* Matrícula: 14/0160299 *)

(* Descrição: Esse arquivo contém uma formalização do algoritmo de ordenação Bubble Sort. Foi usado Fixpoint para a definição recursiva do algoritmo. *)

Require Import List.
Require Import Arith.

Notation "[ ]" := nil.
Notation "[ x ; .. ; y ]" := (cons x .. (cons y nil) ..).

Fixpoint bubble (n : nat) (l : list nat) : list nat :=
  match l with
  | [] => [n]
  | h :: tl => match leb n h with
               | true => n :: bubble h tl
               | false => h :: bubble n tl
               end
  end.

Fixpoint bubbleSort (l : list nat) : list nat :=
  match l with
  | [] => []
  | h :: tl => bubble h (bubbleSort tl)
  end.

Eval compute in bubble 1  (1 :: 2 :: 0 :: 3 :: 1 :: nil).
Eval compute in bubbleSort (1 :: 2 :: 0 :: 3 :: 1 :: nil).
Eval compute in bubbleSort (1 :: 2 :: 0 :: 3 :: 1 :: nil).
Eval compute in bubbleSort (1 :: 2 :: 10 :: 3 :: 6 :: nil).


Fixpoint num_oc (n : nat) (l:list nat) : nat :=
  match l with 
    | [] => 0
    | h :: tl =>
      match eq_nat_dec n h with
        | left _  => S (num_oc n tl)
        | right _ => num_oc n tl 
      end
  end.

Definition equiv l l' := forall n, num_oc n l = num_oc n l'.

Inductive ordenada : list nat -> Prop :=
  | nil_ord : ordenada nil
  | one_ord : forall n:nat, ordenada [n]
  | mult_ord : forall (x y : nat) (l : list nat), ordenada (y :: l) -> le x y -> ordenada (x :: y :: l).

Theorem ex_falso_quodlibet : forall (P:Prop),
  False -> P.
Proof.
  intros P contra.
  destruct contra.  
Qed.

Fact num_oc_fact: forall l n,
    num_oc n (n :: l) = S (num_oc n l).
Proof.
  induction l.
  - simpl.
    intros n.
    destruct (eq_nat_dec n n).
    + reflexivity.
    + unfold not in n0.
      apply ex_falso_quodlibet.
      apply n0; reflexivity.
  - simpl num_oc.
    intros n.
    destruct (eq_nat_dec n n).
    + reflexivity.
    + apply ex_falso_quodlibet.
      apply n0; reflexivity.
Qed.

Lemma num_oc_bubble: forall l n n',
    num_oc n (bubble n' l) =  num_oc n (n' :: l).
Proof.
  induction l.
  - reflexivity.
  - intros n n'.
    destruct (leb n' a) eqn: Hn'a.
    + simpl bubble.
      rewrite -> Hn'a.
      destruct (eq_nat_dec n n') eqn: Hnn'.
      * rewrite -> e.
        simpl num_oc at 1.
        destruct (eq_nat_dec n' n').
        ** rewrite -> IHl.
           rewrite <- num_oc_fact.
           reflexivity.
        ** contradiction.
      * simpl num_oc.
        rewrite Hnn'.
        destruct (eq_nat_dec n a) eqn: Hna.
        ** rewrite <- num_oc_fact.
           rewrite -> IHl.
           rewrite <- e; reflexivity.
        ** rewrite -> IHl.
           simpl.
           rewrite Hna.
           reflexivity.
    + simpl bubble.
      rewrite -> Hn'a.
      destruct (eq_nat_dec n n') eqn: Hnn'.
      * simpl num_oc at 1.
        destruct (eq_nat_dec n' a) eqn: Hn''a.
        ** rewrite -> IHl.
           rewrite <- num_oc_fact.
           rewrite <- e0.
           rewrite Hnn'.
           rewrite -> e; reflexivity.
        ** rewrite -> IHl.
           simpl.
           rewrite e.
           rewrite Hn''a.
           reflexivity.
      * simpl num_oc.
        destruct (eq_nat_dec n a) eqn: Hna.
        ** rewrite IHl.
           rewrite Hnn'.
           assert(H': num_oc n (n' :: l) = num_oc n l).
           { simpl.
             destruct (eq_nat_dec n n') eqn: eq.
             - contradiction.
             - reflexivity.
           }
           rewrite -> H'.
           reflexivity.
        ** rewrite -> IHl.
           rewrite Hnn'.
           assert(H': num_oc n (n' :: l) = num_oc n l).
           { simpl.
             destruct (eq_nat_dec n n') eqn: eq.
             - contradiction.
             - reflexivity.
           }
           rewrite -> H'.
           reflexivity.
Qed.

Lemma bubble_preserva_ordem : forall l n, 
    ordenada l -> ordenada (bubble n l).
Proof.
  induction l.
  - simpl.
    intros.
    apply one_ord.
  - intros n; destruct (leb n a) eqn: Hna.
    + generalize dependent l; destruct l.
      * intros.
        simpl.
        rewrite Hna.
        apply mult_ord.
        ** assumption.
        ** apply leb_complete in Hna; assumption.
      * intros.
        simpl.
        rewrite Hna.
        destruct (leb a n0) eqn: Han0.
        ** apply mult_ord.
           *** inversion H; subst.
               simpl in IHl.
               assert (H': ordenada (if a <=? n0 then a :: bubble n0 l else n0 :: bubble a l)).
               { apply IHl. assumption. }
               rewrite Han0 in H'.
               assumption.
           *** apply leb_complete in Hna; assumption.
        ** inversion H; subst.
           apply Nat.leb_nle in H4.
           apply ex_falso_quodlibet; assumption.
           assumption.
    + intros.
      inversion H; subst.
      * simpl.
        rewrite Hna.
        constructor.
        ** apply one_ord.
        **  apply Nat.leb_gt in Hna.
            apply Nat.lt_le_incl in Hna.
            assumption.
      * simpl in *.
        rewrite Hna.
        destruct (leb n y) eqn: Hny.
        ** apply mult_ord.
           *** assert (IHl': ordenada (if n <=? y then n :: bubble y l0 else y :: bubble n l0)).
              { apply IHl. assumption. }
              rewrite Hny in IHl'.
              assumption.
           *** apply Nat.leb_gt in Hna.
              apply Nat.lt_le_incl in Hna.
              assumption.
        ** constructor.
           *** assert (IHl': ordenada (if n <=? y then n :: bubble y l0 else y :: bubble n l0)).
              { apply IHl. assumption. }
              rewrite Hny in IHl'.
              assumption.
           *** assumption.
Qed.

Theorem correcao: forall l,  (equiv l (bubbleSort l)) /\ ordenada (bubbleSort l).
Proof.
  induction l.
  - simpl.
    split.
    + constructor.
    + apply nil_ord.
  - destruct IHl as [Hequiv Hord].
    split.
    + unfold equiv in *.
      simpl.
      intros n; destruct (eq_nat_dec).
      * assert (H: num_oc n (bubble a (bubbleSort l)) = num_oc n (a :: bubbleSort l)).
      { apply num_oc_bubble. }
      rewrite -> H.
      rewrite -> Hequiv.
      rewrite <- num_oc_fact.
      rewrite <- e.
      reflexivity.
      * rewrite -> num_oc_bubble.
        simpl.
        destruct (eq_nat_dec).
        ** contradiction.
        ** apply Hequiv.
    + simpl.
      apply bubble_preserva_ordem.
      assumption.
Qed.
        
      
Theorem correcao_comp: forall (l:list nat), {l' | equiv l l' /\ ordenada l'}.
Proof.
  intro l.
  exists (bubbleSort l).
  apply correcao.
Qed.
  
Recursive Extraction correcao_comp.
Extraction "Bubble.ml" correcao_comp.
  
