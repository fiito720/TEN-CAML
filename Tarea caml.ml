
(*Funciones extras que son necesarias*)
let car = function x::_ -> x;;
let cdr = function [ ] -> [ ] |
                   _ :: cola -> cola ;;



let rec last = function [ ] -> [ ] |
                        [x] -> x |
                 _ :: resto -> last resto;;

let rec deleteLast = function [ ] -> [ ] |
                        [x] -> [ ] |
                 x :: resto -> x :: deleteLast resto;;


let rec reverse = function [ ] -> [ ] | cab :: cola -> reverse cola @ [ cab ] ;;

let rec lenght = function [] -> 0 |
                    x :: xs -> 1 + lenght xs;;
(*----------------------------------------------------------------------------------*)


(*---------------CODIGO DEL PROYECTO---------------*)

(*RANDOM DEL 1-9*)
(* Semilla inicial para el generador *)
let semilla = ref 123456 ;;

(* Función para generar un número aleatorio entre 1 y 10 *)
let random () = if !semilla <= 0 then semilla := 123456;
  
  (* Actualizamos la semilla utilizando una fórmula básica *)
  semilla := abs ((!semilla * 1664525 + 1013904223) land 0x7FFFFFFF);  (* land para asegurar el rango positivo *)
  
  (* Ajustamos el resultado para que esté entre 1 y 10 *)
  (!semilla mod 9) + 1
;;


(* Metodo de uso
   random ();;    *)

(*GENERA FILAS DE n ELEMENTOS ALEATORIOS*)
(* Función para generar una fila de n elementos aleatorios *)
let rec generarFila = function 0 -> [] |
    n -> random () :: generarFila (n - 1);;

(*Esta funcion recibe n el cual es la cantidad de filas. Como mi juego inicia con 3, 
se le pasa un n de 3. Las columnas siempre seran 9
NECESITA DE generarFila n*)
let rec construirTablero = function 0 -> [] |
    n -> generarFila 9 :: construirTablero (n - 1);;


(*FUNCIONES PARA IMPRIMIR*)
(*Muestra en bonito una fila del tablero*)
let rec imprimirFila = function [] -> () |
    x :: xs -> print_int x; print_string " "; imprimirFila xs;;


(*FUNCIONES PARA ACCESAR A UN ELEMENTO DEL TABLERO PASANDOLE LA FILA Y COMLUMNA*)

(*NECESITA car y cdr*)
let rec getElem2 = fun tablero c -> if c = 1 then car tablero else getElem2 (cdr tablero) (c-1);;

(*funcion que recibe el tablero, la fila y la columna
NECESITA car y cdr*)
let rec getElem = fun tablero f c -> if f = 1 then (getElem2 (car tablero) c) else getElem (cdr tablero) (f-1) c;;

(*----------------------------------------------------------------------------------*)
let rec setElem2 = function [] -> (function c -> function nuevo_valor -> []) |
                            cab :: cola -> (function c -> function nuevo_valor ->
                                if c = 1 then 
                                    (nuevo_valor :: cola)
                                else 
                                    cab :: (setElem2 cola (c - 1) nuevo_valor));;


let rec setElem = function [] -> (function f -> function c -> function nuevo_valor -> []) |
                            fila :: filas -> (function f -> function c -> function nuevo_valor ->
                                if f = 1 then 
                                    ((setElem2 fila c nuevo_valor) :: filas)
                                else 
                                    fila :: (setElem filas (f - 1) c nuevo_valor));;




(*DAMOS INICIO AL JUEGO*)
(*Definicion  del estado del juego*)
let estado = ref ((construirTablero 3), 1, 6, 0);;
let (tablero, nivel, repart_p, puntos) = !estado;;

(*FUNCIONES PARA RESETEAR EL JUEGO*)
let resetear () = estado:= ((construirTablero 3), 1, 6, 0);;

(*Muestra en bonito el tablero
NECESITA imprimirFila*)
let rec mostrarTablero2 = function [] -> () |
    fila :: tab -> imprimirFila fila; print_newline (); mostrarTablero2 tab;;

let mostrarTablero () = let (tablero, nivel, repart_p, puntos) = !estado in mostrarTablero2 tablero; print_newline ();;



(*----------------------------------------------------------------------------------*)
(*FUNCIONES PARA ACTULIZAR EL ESTADO DEL JUEGO*)
let nuevoTablero = fun tab -> let (tablero, nivel, repart_p, puntos) = !estado in estado := (tablero, nivel, repart_p, puntos);;

let incrementarNivel () = let (tablero, nivel, repart_p, puntos) = !estado in estado := (tablero, nivel + 1, repart_p, puntos);;

let restarRepartir () = let (tablero, nivel, repart_p, puntos) = !estado in estado := (tablero, nivel, repart_p - 1, puntos);;

let sumarPuntos = fun p -> let (tablero, nivel, repart_p, puntos) = !estado in estado := (tablero, nivel, repart_p, puntos + p);;
(*----------------------------------------------------------------------------------*)


(*FUNCIONES PARA COMPROBAR EL ESTADO DEL TABLERO
- Vefrica si hay alguna fila llena de ceros para eliminarla y sumar puntos
*)
let rec hayFilaCero = function [] -> true |
    elem :: elems -> if elem = 0 then hayFilaCero elems else false;;
    
let rec comprobarEstadoTablero = function [] -> [] |
    fila :: filas -> if (hayFilaCero fila) then( 
                        sumarPuntos 10;
                        filas
                        ) else fila :: comprobarEstadoTablero filas;;


(*FUNCIONES PARA REALIZAR MOVIMIENTOS - coloca los 0 correspondientes a las casillas seleccionadas*)
let realizarMovidad = fun f1 c1 f2 c2 -> (*Coloca los 0 en las casillas jugadas y actuliza el tablero*)
                                        let (tablero, nivel, repart_p, puntos) = !estado in
                                        estado := ((setElem tablero f1 c1 0), nivel, repart_p, puntos);

                                        let (tablero, nivel, repart_p, puntos) = !estado in
                                        estado := ((setElem tablero f2 c2 0), nivel, repart_p, puntos);
                                        
                                        (*Comprueba el estado del tablero*)
                                        let (tablero, nivel, repart_p, puntos) = !estado in
                                        estado := ((comprobarEstadoTablero tablero), nivel, repart_p, puntos);;



(*---------------------------------------------------------------------------------------------------------------------*)
(*FUNCIONES PARA REALIZAR MOVIMIENTOS EN HORIZONTAL Y VERTICAL*)
let rec comprobarHorizontal = fun tablero f1 c1 f2 c2 n -> if (c1 = c2) then true else
                                                        if (c1 < c2) then(
                                                            if (n = 0) then( 
                                                                comprobarHorizontal tablero f1 (c1+1) f2 c2 1
                                                            )else if ((getElem tablero f1 c1) = 0) then( 
                                                                comprobarHorizontal tablero f1 (c1+1) f2 c2 n
                                                            )else 
                                                                false
                                                        )else (
                                                            if (n = 0) then( 
                                                                comprobarHorizontal tablero f1 c1 f2 (c2+1) 1
                                                            )else if ((getElem tablero f2 c2) = 0) then( 
                                                                comprobarHorizontal tablero f1 c1 f2 (c2+1) n
                                                            )else
                                                                false
                                                        );;

let rec comprobarVertical = fun tablero f1 c1 f2 c2 n -> if (f1 = f2) then true else
                                                        if (f1 < f2) then(
                                                            if (n = 0) then( 
                                                                comprobarVertical tablero (f1+1) c1 f2 c2 1
                                                            )else if ((getElem tablero f1 c1) = 0) then( 
                                                                comprobarVertical tablero (f1+1) c1 f2 c2 n
                                                            )else 
                                                                false
                                                        )else (
                                                            if (n = 0) then( 
                                                                comprobarVertical tablero f1 c1 (f2+1) c2 1
                                                            )else if ((getElem tablero f2 c2) = 0) then( 
                                                                comprobarVertical tablero f1 c1 (f2+1) c2 n
                                                            )else
                                                                false
                                                        );;


let rec comprobarDiagonal = fun tablero f1 c1 f2 c2 n tam_f tam_c -> if ((f1 = f2) && (c1 = c2)) then true
                                                                else if ((f1<=tam_f) & (f2<=tam_f) & (c1 <= tam_c) & (c2 <= tam_c)) then(
                                                                    if (f1 < f2) then(
                                                                        if (c1 < c2) then(
                                                                            if (n = 0) then(
                                                                                comprobarDiagonal tablero (f1+1) (c1+1) f2 c2 1 tam_f tam_c
                                                                            )else if ((getElem tablero f1 c1) = 0) then(
                                                                                comprobarDiagonal tablero (f1+1) (c1+1) f2 c2 n tam_f tam_c
                                                                            )else
                                                                                false
                                                                        )else( (*c1 > c2*)
                                                                            if (n = 0) then(
                                                                                comprobarDiagonal tablero (f1+1) (c1-1) f2 c2 1 tam_f tam_c
                                                                            )else if ((getElem tablero f1 c1) = 0) then(
                                                                                comprobarDiagonal tablero (f1+1) (c1-1) f2 c2 n tam_f tam_c
                                                                            )else(
                                                                                false
                                                                            )
                                                                        )
                                                                    )else( (*f1 > f2*)
                                                                        if (c1 < c2) then(
                                                                            if (n = 0) then(
                                                                                comprobarDiagonal tablero (f1-1) (c1+1) f2 c2 1 tam_f tam_c
                                                                            )else if ((getElem tablero f1 c1) = 0) then(
                                                                                comprobarDiagonal tablero (f1-1) (c1+1) f2 c2 n tam_f tam_c
                                                                            )else
                                                                                false
                                                                        )else( (*c1 > c2*)
                                                                            if (n = 0) then(
                                                                                comprobarDiagonal tablero (f1-1) (c1-1) f2 c2 1 tam_f tam_c
                                                                            )else if ((getElem tablero f1 c1) = 0) then(
                                                                                comprobarDiagonal tablero (f1-1) (c1-1) f2 c2 n tam_f tam_c
                                                                            )else
                                                                                false
                                                                        )
                                                                    )
                                                                ) else false;;

(*FUNCIONES PARA COMPROBAR EL PRIMER NIVEL*)
(*Comprueba si el numero de f1c1 y el de f2c2 son iguales o si sumados dan 10*)  
let comprobarPrimerNivel = fun f1 c1 f2 c2 -> let (tablero, nivel, repart_p, puntos) = !estado in
                                              if (f1 = f2 && c1 = c2) then false else
                                              if ((getElem tablero f1 c1) = 0 || (getElem tablero f2 c2) = 0) then false else
                                              if ((getElem tablero f1 c1) = (getElem tablero f2 c2) || (getElem tablero f1 c1) + (getElem tablero f2 c2) = 10) 
                                              then(
                                                if ((abs (f1-f2) <=1) && (abs (c1-c2) <=1)) then(
                                                    (*Llama la funcion de sumar puntos*)
                                                    sumarPuntos 1;

                                                    (*Coloca los 0 en las casillas jugadas y actuliza el tablero*)
                                                    (realizarMovidad f1 c1 f2 c2);

                                                    true
                                                ) else if (f1 = f2) then(
                                                    let (tablero, nivel, repart_p, puntos) = !estado in
                                                    if (((getElem tablero f1 c1) = (getElem tablero f2 c2) || (getElem tablero f1 c1) + (getElem tablero f2 c2) = 10) & (comprobarHorizontal tablero f1 c1 f2 c2 0)) then(
                                                        (*Llama la funcion de sumar puntos*)
                                                        sumarPuntos 4;

                                                        (*Coloca los 0 en las casillas jugadas y actuliza el tablero*)
                                                        (realizarMovidad f1 c1 f2 c2);

                                                        true
                                                    ) else false
                                                ) else if (c1 = c2) then(
                                                    let (tablero, nivel, repart_p, puntos) = !estado in
                                                    if (((getElem tablero f1 c1) = (getElem tablero f2 c2) || (getElem tablero f1 c1) + (getElem tablero f2 c2) = 10) & (comprobarVertical tablero f1 c1 f2 c2 0)) then(
                                                        (*Llama la funcion de sumar puntos*)
                                                        sumarPuntos 4;

                                                        (*Coloca los 0 en las casillas jugadas y actuliza el tablero*)
                                                        (realizarMovidad f1 c1 f2 c2);

                                                        true
                                                    ) else false
                                                ) else (
                                                    let (tablero, nivel, repart_p, puntos) = !estado in
                                                    if (((getElem tablero f1 c1) = (getElem tablero f2 c2) || (getElem tablero f1 c1) + (getElem tablero f2 c2) = 10) & (comprobarDiagonal tablero f1 c1 f2 c2 0 (lenght tablero) 9)) then(
                                                        (*Llama la funcion de sumar puntos*)
                                                        sumarPuntos 4;

                                                        (*Coloca los 0 en las casillas jugadas y actuliza el tablero*)
                                                        (realizarMovidad f1 c1 f2 c2);

                                                        true
                                                    ) else false
                                                )
                                              )
                                              else false;;


(*---------------------------------------------------------------------------------------------------------------------*)
(*FUNCIONES DE REPARTIR*)

(*funcion auxiliar de pegar repartir*)
let rec quitarPrimerosCeros = function [] -> [] |
    cab :: cola -> if cab = 0 then quitarPrimerosCeros cola else cab ::  cola;;

(*Funciones que al final me devuelven un int list con los digitos dupicados sin 0*)
let rec quitarCeros = function [] -> [] |
    cab :: cola -> if cab = 0 then quitarCeros cola else cab :: quitarCeros cola;;

let rec extraerDigitos = function [] -> [] |
    x :: xs -> (quitarCeros x) @ (extraerDigitos xs);;

(*Funcion que transforma lo que queda de la lista por duplicar, en las filas restantes de la matriz*)
let rec armarFilasDeRepartir = fun lista nuevaLista n tab -> 
    if (lista = [] && n = 0) 
        then (tab @ [nuevaLista] ) 
    else if (lista = [] && n <> 0) 
        then (armarFilasDeRepartir [] (nuevaLista @ [0]) (n-1) tab) 
    else if (lista <> [] && n = 0) 
        then (armarFilasDeRepartir lista [] 9 (tab @ [nuevaLista]))
    else
        (armarFilasDeRepartir (cdr lista) (nuevaLista @ [car lista]) (n-1) tab) ;;

(*Funcion que pega mi tablero original sin la ultima fila con las nuevas filas transformadas
La ultima fila, realmente no es borrada sino que es transformada, ya que si sus ultimos digitos
son 0, cuando se reparte, esos espacios deben de ser rellenados*)
let rec pegarRepartir = fun tab -> nuevoTablero ((deleteLast tab) @ (armarFilasDeRepartir 
                                                                    (extraerDigitos tab)
                                                                    (reverse (quitarPrimerosCeros (reverse (last tab))))
                                                                    (9 - (lenght (reverse (quitarCeros (reverse (last tab))))))
                                                                    []));;



(*Realiza movida en le juego
NECESITA DE comprobarPrimerNivel*)
let par = fun f1 c1 f2 c2 -> (comprobarPrimerNivel f1 c1 f2 c2);
                              mostrarTablero ();;

let rec repartir () = 
    let (tablero, nivel, repart_p, puntos) = !estado in
    pegarRepartir tablero;
    restarRepartir ();
    mostrarTablero ();;


