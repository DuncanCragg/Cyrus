package net.minecraft.src;

import java.util.*;
import java.util.concurrent.*;
import java.io.*;

import cyrus.Version;
import cyrus.Cyrus;
import cyrus.platform.Kernel;
import cyrus.lib.JSON;
import cyrus.forest.*;

import static cyrus.lib.Utils.*;

import net.minecraft.client.*;
import net.minecraft.server.MinecraftServer;

public class mod_Cyrus extends BaseMod {

    public String getName() { return this.getClass().getSimpleName(); }

    public String getVersion(){ return "Cyrus Minecraft Mod 0.01"; }

    public String toString() { return this.getName() + ' ' + this.getVersion(); }

    public static mod_Cyrus modCyrus;

    public void load(){

        InputStream configis=this.getClass().getClassLoader().getResourceAsStream("cyrusconfig.db");
        JSON config=null;
        try{ config = new JSON(configis,true); }catch(Exception e){ throw new RuntimeException("Error in config file: "+e); }

        modCyrus=this;

        ModLoader.setInGameHook(this, true, true);
        ModLoader.setInGUIHook(this, true, true);
        ModLoader.registerKey(this, new KeyBinding("Alt-Tab", 0xa5), true);

        System.out.println("-------------------");
        System.out.println(Version.NAME+" "+Version.NUMBERS);
        Kernel.init(config, new FunctionalObserver());
        Kernel.run();
    }

    MinecraftEntity thePlayer=null;

    public void registerPlayer(MinecraftEntity player){ thePlayer=player; }

    public void clientConnect(NetClientHandler nch){
        Minecraft mc=Minecraft.getMinecraft();
        EnumGameType gt=getGameType(mc);
        mc.playerController = new PlayerControllerMP(mc, nch){
            int ticks=0;
            public void clickBlock(int x, int y, int z, int sideHit){
                super.clickBlock(x,y,z,sideHit);
                if(thePlayer!=null) thePlayer.onInteracting("hitting", x,y,z,sideHit);
                ticks=1;
            }
            public void onPlayerDamageBlock(int x, int y, int z, int sideHit){
                super.onPlayerDamageBlock(x,y,z,sideHit);
                if(thePlayer!=null) thePlayer.onInteracting("hitting", x,y,z,sideHit);
                ticks=1;
            }
            public boolean onPlayerRightClick(EntityPlayer player, World world, ItemStack items, int x, int y, int z, int sideHit, Vec3 hitVec){
                boolean r=super.onPlayerRightClick(player, world, items, x, y, z, sideHit, hitVec);
                if(thePlayer!=null) thePlayer.onInteracting("placing", x,y,z,sideHit);
                ticks=1;
                return r;
            }
            public void attackEntity(EntityPlayer player, Entity entityHit){
                super.attackEntity(player, entityHit);
                if(thePlayer!=null) thePlayer.onInteracting("hitting", entityHit);
                ticks=1;
            }
            public boolean func_78768_b(EntityPlayer player, Entity entityHit){
                boolean r=super.func_78768_b(player, entityHit);
                if(thePlayer!=null) thePlayer.onInteracting("touching", entityHit);
                ticks=1;
                return r;
            }
            static final int WAITTICKS=6;
            public void updateController(){
                if(ticks==0 || thePlayer==null) return;
                if(ticks< WAITTICKS){ ticks++; return; }
                thePlayer.onNotInteracting("hitting");
                thePlayer.onNotInteracting("placing");
                thePlayer.onNotInteracting("touching");
                ticks=0;
            }
        };
        mc.playerController.setGameType(gt);
    }

    EnumGameType getGameType(Minecraft mc){
        // world.getWorldInfo().getGameType() == EnumGameType.ADVENTURE
        return mc.playerController.isInCreativeMode()? EnumGameType.CREATIVE: EnumGameType.SURVIVAL;
    }

    public interface Tickable { public void tick(float var1, Minecraft minecraft); }

    CopyOnWriteArrayList<Tickable> tickables=new CopyOnWriteArrayList<Tickable>();

    public void registerTicks(Tickable tickable){ tickables.add(tickable); }

    public boolean onTickInGame(float var1, Minecraft minecraft){
        if(!checkIfNewWorld()) return true;
        for(Tickable tickable: tickables){
            long s=System.currentTimeMillis();
            tickable.tick(var1, minecraft);
            long e=System.currentTimeMillis();
            if(e-s > 50) log("***** Tick took "+(e-s)+"ms for:\n"+tickable);
        }
        return true;
    }

    String worldname=null;

    private boolean checkIfNewWorld(){
        MinecraftServer server=MinecraftServer.getServer();
        if(server==null) return false;
        World world=server.worldServerForDimension(0);
        if(world==null) return false;
        String name=world.worldInfo.getWorldName();
        if(name==null) return false;
        if(!name.equals(worldname)){
            worldname=name;
            MinecraftCyrus.newWorld(worldname,world);
        }
        return true;
    }

    public boolean onTickInGUI(float var1, Minecraft minecraft, GuiScreen var3) { return true; }

    //  EntityPlayerMP :: item.egg
    public void onItemPickup(EntityPlayer player, ItemStack itemStack){}

    public void keyboardEvent(KeyBinding var1) { logXX("key "+var1); }
/*
    public void modsLoaded() {}

    public void generateNether(World var1, Random var2, int var3, int var4) {}

    public void generateSurface(World var1, Random var2, int var3, int var4) {}

    public void addRenderer(Map var1) {}

    public String getPriorities() { return ""; }

    public void registerAnimation(Minecraft var1) {}

    public void renderInvBlock(RenderBlocks var1, Block var2, int var3, int var4) {}

    public boolean renderWorldBlock(RenderBlocks var1, IBlockAccess var2, int var3, int var4, int var5, Block var6, int var7) { return false; }

    public void clientDisconnect(NetClientHandler var1) { }

    public int addFuel(int var1, int var2) { return 0; }

    public void takenFromCrafting(EntityPlayer var1, ItemStack var2, IInventory var3) {}

    public void takenFromFurnace(EntityPlayer var1, ItemStack var2) {}

    public GuiContainer getContainerGUI(EntityClientPlayerMP var1, int var2, int var3, int var4, int var5) { return null; }

    public Entity spawnEntity(int var1, World var2, double var3, double var5, double var7) { return null; }

    public void clientChat(String var1) {}

    public void serverChat(NetServerHandler var1, String var2) {}

    public void clientCustomPayload(NetClientHandler var1, Packet250CustomPayload var2) {}

    public void serverCustomPayload(NetServerHandler var1, Packet250CustomPayload var2) {}

    public Packet23VehicleSpawn getSpawnPacket(Entity var1, int var2) { return null; }
*/
}


