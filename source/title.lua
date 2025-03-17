local pd = playdate
local gfx = pd.graphics

function titleUpdate()
    gfx.clear()
    
    -- Draw A button text
    gfx.drawText("Press A to Start", 100, 100)
    
    -- Draw B button text
    gfx.drawText("Press B to Quit", 100, 130)
end