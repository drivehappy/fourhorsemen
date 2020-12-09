module NetworkMessages

open Codegen.Proto
open System.Security.Cryptography
open System.Text


//
let buildClientId (ip : string) (port : string) (salt : byte[]) =
    use hash = SHA256.Create()

    (System.Convert.ToBase64String(salt)) + ":" + ip + ":" + port
    |> Encoding.ASCII.GetBytes
    |> hash.ComputeHash
    |> System.Convert.ToBase64String
    

//
let handleClientMessage (clientId : string) (pbCSMain : CS_Main) : SC_Main option =
    let root = new SC_Main()
    root.Type <- SC_Main.Types.Type.InitialState
    root.AssignedPlayerId <- clientId

    Some root
