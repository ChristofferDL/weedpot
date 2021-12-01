include("shared.lua")

surface.CreateFont("Weed_Title", { font = "Roboto", size = 25, weight = 500})
surface.CreateFont("Weed_Items", { font = "Roboto", size = 18, weight = 500})

function ENT:Draw()
	self:DrawModel()
end

net.Receive("Weed_Open_Menu", function()
	local ply = net.ReadEntity()
	local frame = vgui.Create("DFrame")
	frame:SetSize(200,300)
	frame:Center()
	frame:MakePopup()
	frame:SetSizable(false)
	frame:SetDraggable(false)
	frame:ShowCloseButton(false)
	frame:SetTitle("Weed Seeds")
	frame.Paint = function(self,w,h)
		draw.RoundedBoxEx(5, 0, 20, w, h - 20, Custom_Weedpots.Config.Background, false, false, true, true)
		draw.RoundedBoxEx(5, 0, 0, w, 20, Custom_Weedpots.Config.Header, true, true, false, false)
	end
	frame.close = vgui.Create("DButton", frame)
	frame.close:SetSize(10,20)
	frame.close:SetPos(frame:GetWide()/1.1,0 - 4)
	frame.close:SetText("")
	frame.close.DoClick = function()
		frame:Remove()
	end
	frame.close.Paint = function(self,w,h)
		draw.SimpleText("x", "Weed_Title", 0, 0, color_white)
	end

	for k,v in pairs(Custom_Weedpots.Types) do
		local types = vgui.Create("DButton", frame)
		types:SetSize(0, 40)
		types:SetText(v.name)
		types:Dock(TOP)
		types:DockMargin(0, 0, 0, 5)
		types:SetText("")
		types:SetTooltip("Growth time: " .. v.time .. " seconds")
		types.DoClick = function()
			net.Start("Seed_Purchase")
			net.WriteString(v.name)
			net.WriteInt(v.time, 32)
			net.WriteInt(v.sellMin, 32)
			net.WriteInt(v.sellMax, 32)
			net.WriteInt(v.price, 32)
			net.SendToServer()
			frame:Remove()
		end
		types.Paint = function(self,w,h)
			draw.RoundedBox(4,0,0,w,h,Custom_Weedpots.Config.Items)
			draw.SimpleText(v.name .. "(" .. DarkRP.formatMoney(v.price) .. ")", "Weed_Items", types:GetWide() / 2, types:GetTall() / 2, v.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end)