(* Note: this file must be run at root directory of the project. Otherwise the
Sys.command calls below happen in the wrong directory *)

let folders = [
  (* (directory, number of tests) *)
  ("1_bad_file_name", 1);
  ("file_IllegalCharacter", 1);
  ("file_SyntaxError", 3);
  ("type_AppliedTooMany", 1);
  ("type_AppliedWithoutLabel", 1);
  ("type_IncompatibleType", 2);
  ("type_NotAFunction", 1);
  ("type_RecordFieldNotBelong", 2);
  ("type_RecordFieldsUndefined", 1);
  ("type_UnboundRecordField", 2);
  ("type_UnboundTypeConstructor", 1);
  ("type_UnboundValue", 2);
  ("warning_OptionalArgumentNotErased", 1);
]

exception Not_equal of string

let () =
  List.iter (fun (dirname, fileCount) -> for i = 1 to fileCount do
    let testsDirname = Filename.concat "tests" dirname in
    let filename = Filename.concat testsDirname (Printf.sprintf "%s_%d.ml" dirname i) in
    let expectedOutputName = Filename.concat testsDirname (Printf.sprintf "%s_%d_expected.txt" dirname i) in
    let actualOutputName = Filename.concat testsDirname (Printf.sprintf "%s_%d_actual.txt" dirname i) in
      (* expecting compiling errors in stderr; pipe to a file *)
      ignore @@ Sys.command @@ Printf.sprintf "ocamlc %s 2> %s" filename actualOutputName;
      (* open the produced error output *)
      BatFile.with_file_in expectedOutputName (fun inp ->
        let expected = BatIO.read_all inp in
        BatFile.with_file_in actualOutputName (fun inp2 ->
          let actual = BatIO.read_all inp2 in
          if actual = expected then () else raise (Not_equal filename)
        )
      )

  done) folders;
  print_endline "ALL GOOD!"