if SERVER then
    hook.Remove("CanTool", "FPP.Protect.CanTool")
else
    hook.Remove("CanTool", "FPP_CL_CanTool")
end