(*
Определения:
Множество идентификаторов кортежей: L ∈ ℕ₀
Множество идентификаторных кортежей длины n ∈ ℕ₀: Tn ⊆ Lⁿ.
Множество ассоциаций: A ⊆ L × Tn.
Семейство функций: ∪_n {netⁿ | n ∈ ℕ₀} ⊆ A
Здесь ∪ обозначает объединение всех функций в семействе {netⁿ}, ⊆ обозначает "это подмножество", а A - пространство всех ассоциаций. Это говорит о том, что все упорядоченные пары, полученные от функций netⁿ, являются подмножеством A.
Ассоциативная сеть кортежей длины n из семейства функций {netⁿ}, netⁿ : L → Tn отображает идентификатор l из множества L в идентификаторный кортеж длины n, который принадлежит множеству Tn. 'n' в netⁿ указывает на то, что функция возвращает кортежи, содержащие n идентификаторов. 
Ассоциативная сеть дуплетов: net² : L → T₂.
Ассоциативная сеть вложенных упорядоченных пар: net : L → P, где P = {(∅,∅) | (l,∅) | (l1,l2), l, l1, l2 ∈ L} - это множество вложенных упорядоченных пар, которое состоит из пустых пар, пар, содержащих только один элемент, и пар, содержащих два элемента.
Дополнительные пояснения:
Кортеж длины n ∈ ℕ₀ можно представить как вложенные упорядоченные пары.
Идентификатор кортежа - уникальный идентификатор, каждый из которых связан с определенным кортежем.
Идентификаторный кортеж - это кортеж, состоящий из нуля или нескольких идентификаторов кортежей, где количество индексов соответствует количеству элементов кортежа.
Ассоциация - это упорядоченная пара, состоящая из идентификатора кортежа и кортежа идентификаторов. Эта структура служит для отображения между идентификаторами и кортежами.
Пустой кортеж представлен пустым множеством: () представлено как ∅.

Гипотеза 1: после преобразования ассоциативной сети кортежей фиксированной длины n
 в ассоциативную сеть вложенных упорядоченных пар, а затем обратно в ассоциативную сеть кортежей длины n,
 мы получим исходную ассоциативную сеть кортежей.

Гипотеза 2: Для ассоциативной сети дуплетов dupletNet: DupletNet
 существует эквивалентная сеть вложенных упорядоченных пар nestedPairsNet: NestedPairsNet,
 такая что для каждого идентификатора l: L:
Если dupletNet l = (l1, l0), тогда nestedPairsNet l = Doublet l1 Empty.
Если dupletNet l = (l1, l2) и l2 ≠ l0, тогда nestedPairsNet l = Doublet l1 (Doublet l2 Empty).

Гипотеза 3: Ассоциативная сеть дуплетов может представлять любую ассоциативную сеть.
*)

(* Определяем базовый тип идентификаторов *)
Definition L := nat.
Definition l0 := 0.

Section NestedPairsNets.
  (* Определение вложенной пары с переменной длиной *)
  Inductive NestedPair: Type :=
  | Empty: NestedPair
  | Doublet: L -> (NestedPair) -> NestedPair.

  (* Определение ассоциативной сети с вложенными парами *)
  Definition NestedPairsNet : Type := L -> NestedPair. 
End NestedPairsNets.

Fixpoint depth (p : NestedPair) : nat :=
  match p with
  | Empty => 0
  | Doublet _ p' => S (depth p')
  end.

Section DupletNets.  
  (* Определение дуплета *)
  Definition Duplet := prod L L.

  (* Определение ассоциативной сети дуплетов *)
  Definition DupletNet : Type := L -> Duplet.
End DupletNets.

Fixpoint nestedPairsNet_to_dupletNetAux (nestedPairsNet: NestedPairsNet) (l: L) (counter: L): DupletNet :=
  fun l' =>
  match n with
  | 0 =>  (l0, l0)  (* Here we suppose, that depth of NestedPair is limited by number n *)
  | S n' => match nestedPairsNet l with
            | Empty => if l' =? l then (l0, l0)   (* Here we suppose, that l0 - is correct identifier for Empty *)
                                 else (nestedPairsNet_to_dupletNetAux nestedPairsNet n' l' (counter + 1)) l'
            | Doublet l1 pair1 => if l' =? l then (l1, counter)
                                              else (nestedPairsNet_to_dupletNetAux nestedPairsNet n' counter (counter + 1)) l'
            end
  end.

Definition nestedPairsNet_to_dupletNet (nestedPairsNet: NestedPairsNet) (n: nat): DupletNet :=
  fun l => (nestedPairsNet_to_dupletNetAux nestedPairsNet n l l) l.

Section TuplesNets.
  (* Определение кортежа фиксированной длины n *)
  Fixpoint Tuple (n: nat) : Type :=
    match n with
    | 0 => unit
    | S n' => prod L (Tuple n')
    end.

  (* Определение ассоциативной сети кортежей фиксированной длины n *)
  Definition TuplesNet (n: nat) : Type := L -> Tuple n.
End TuplesNets.

Fixpoint tupleToNestedPair {n: nat} : Tuple n -> NestedPair :=
  match n with
  | 0 => fun _ => Empty
  | S n' => 
      fun t => 
        match t with
        | (f, rest) => Doublet f (tupleToNestedPair rest)
        end
  end.

Definition tuplesNetToPairsNet {n: nat} (f: TuplesNet n) : NestedPairsNet:=
  fun id => tupleToNestedPair (f id).

(* Лемма о сохранении глубины: *)
Lemma depth_preserved : forall {l: nat} (t: Tuple l), depth (tupleToNestedPair t) = l.
Proof.
  intros l. induction l as [| l' IH]; intros t.
  - (* Базовый случай *)
    simpl. reflexivity.
  - (* Шаг индукции *)
    destruct t as [x t']. simpl.
    destruct l'.
    + simpl. reflexivity.
    + simpl. f_equal. apply IH.
Qed.

Fixpoint nestedPairToTupleOption (n: nat) (p: NestedPair) : option (Tuple n) :=
  match n, p with
  | 0, Empty => Some tt
  | S n', Doublet f p' => 
      match nestedPairToTupleOption n' p' with
      | None => None
      | Some t => Some (f, t)
      end
  | _, _ => None
  end.

Definition pairsNetToTuplesNetOption {n: nat} (f: NestedPairsNet) : L -> option (Tuple n) :=
  fun id => nestedPairToTupleOption n (f id).

Definition pairsNetToTuplesNet { n: nat } (net: NestedPairsNet) (default: Tuple n) : TuplesNet n :=
  fun id => match nestedPairToTupleOption n (net id) with
            | Some t => t
            | None => default
            end.

(* Лемма о взаимном обращении функций nestedPairToTupleOption и tupleToNestedPair *)
Lemma H_inverse: forall n: nat, forall t: Tuple n, nestedPairToTupleOption n (tupleToNestedPair t) = Some t.
Proof.
  intros n. induction n as [| n' IH]; intros t.
  - (* Базовый случай *)
    destruct t. reflexivity.
  - (* Шаг индукции *)
    destruct t as [x t']. simpl.
    rewrite IH. reflexivity.
Qed.

Definition nets_equiv {n: nat} (net1: TuplesNet n) (net2: TuplesNet n) : Prop :=
  forall id, net1 id = net2 id.

(* Лемма - эквивалентность после преобразования *)
Lemma nets_equiv_after_transforms : forall {n: nat} (net: TuplesNet n),
  nets_equiv net (fun id => match nestedPairToTupleOption n ((tuplesNetToPairsNet net) id) with
                            | Some t => t
                            | None   => net id
                            end).
Proof.
  intros n net id.
  unfold tuplesNetToPairsNet.
  simpl.
  rewrite H_inverse.
  reflexivity.
Qed.


Definition complexExampleNet : TuplesNet 3 :=
  fun id => match id with
  | 0 => (0, (0, (0, tt)))
  | 1 => (1, (1, (0, tt)))
  | 2 => (2, (0, (0, tt)))
  | 3 => (3, (0, (0, tt)))
  | 4 => (4, (0, (0, tt)))
  | S _ => (0, (0, (0, tt)))
  end.

Definition exampleTuple0 : Tuple 0 := tt.
Definition exampleTuple1 : Tuple 1 := (0, tt).
Definition exampleTuple4 : Tuple 4 := (3, (2, (1, (0, tt)))).
Definition nestedPair0 := tupleToNestedPair exampleTuple0.
Definition nestedPair1 := tupleToNestedPair exampleTuple1.
Definition nestedPair4 := tupleToNestedPair exampleTuple4.
Check nestedPair0.
Check nestedPair1.
Check nestedPair4.
Compute nestedPair0.
Compute nestedPair1.
Compute nestedPair4.

Compute (tuplesNetToPairsNet complexExampleNet) 0.
Compute (tuplesNetToPairsNet complexExampleNet) 1.
Compute (tuplesNetToPairsNet complexExampleNet) 2.
Compute (tuplesNetToPairsNet complexExampleNet) 3.
Compute (tuplesNetToPairsNet complexExampleNet) 4.
Compute (tuplesNetToPairsNet complexExampleNet) 5.

Definition testPairsNet : NestedPairsNet :=
  fun _ => Doublet 1 (Doublet 2 (Doublet 0 Empty)).

Definition testTupleDefault : Tuple 3 := (0, (0, (0, tt))). 

Definition testTuplesNet : TuplesNet 3 :=
  pairsNetToTuplesNet testPairsNet testTupleDefault.

Compute testTuplesNet 0.


