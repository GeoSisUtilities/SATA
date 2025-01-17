@echo off

taskkill /F /IM PDFelement.exe

where python > py
set "py=py"
for /F "delims=" %%x in (%py%) do (
     set "py=%%x"
)
set "cpt_file=cpt_file"
set "coord_gmt=temp/coord_gmt"
for /F "delims=" %%x in (%coord_gmt%) do (
     set "coord_gmt=%%x"
)
set "length_sect=temp/length_sect"
for /F "delims=" %%x in (%length_sect%) do (
     set "length_sect=%%x"
)
set "depth=temp/depth"
for /F "delims=" %%x in (%depth%) do (
     set "depth=%%x"
)
set "start_lat=temp/start_lat"
for /F "delims=" %%x in (%start_lat%) do (
     set "start_lat=%%x"
)
set "start_lon=temp/start_lon"
for /F "delims=" %%x in (%start_lon%) do (
     set "start_lon=%%x"
)
set "end_lat=temp/end_lat"
for /F "delims=" %%x in (%end_lat%) do (
     set "end_lat=%%x"
)
set "end_lon=temp/end_lon"
for /F "delims=" %%x in (%end_lon%) do (
     set "end_lon=%%x"
)

set "old_earthquakes=temp/old_earthquakes"
set "last_earthquake=temp/last_earthquake"
set "old_earthquake_nohead=temp/old_earthquake_nohead"
set "coord_section_map_view=temp/coord_section_map_view"
set "table_last_eqs=temp/table_last_eqs.png"
dir /b "DISS_gmt/vertex_sources" > temp/fault_list
set "fault_list=temp/fault_list"

gmt makecpt -Crainbow -T0/100/2 -Z > %cpt_file%
gmt begin combined_plots
    gmt subplot begin 2x2 -Fs14c/8c -M1.2c
        REM Primo subplot: mappa_sismicita_scaled_mg_depth_full_italy
        gmt subplot set 0,0
        gmt coast -R6/19/36/48 -JM6i -B -Glightgray -Na0.5 -B+glightblue -W0.3p,black
        gmt grdimage @earth_gebco_02m -R6/19/36/48 -JM6i -t80
        gmt psxy DISS_gmt/CSSTOP321.gmt -R6/19/36/48 -JM6i -W0.5,red -t60
        gmt psxy DISS_gmt/CSSPLN321.gmt -R6/19/36/48 -JM6i -W0.1 -G"#FF0000AA" -t75
        gmt plot DISS_gmt/Cities.txt -R6/19/36/48 -JM6i -SS0.1c -Wblack -Gwhite
        gmt text DISS_gmt/Cities.txt -R6/19/36/48 -JM6i -F+f5p,black -D0.15/0.15
        gmt plot %old_earthquakes% -Wfaint -R6/19/36/48 -JM6i -i7,6,8,9+s0.05 -Scc -C%cpt_file%
        gmt plot %coord_section_map_view% -R6/19/36/48 -JM6i -Wblack
        gmt plot %coord_section_map_view% -R6/19/36/48 -JM6i -Sc0.1c -Wblack
        gmt plot %last_earthquake% -Wfaint -R6/19/36/48 -JM6i -i7,6,8,9 -Sa0.28 -Gyellow
        REM Secondo subplot: mappa_sism_zoom
        gmt subplot set 0,1
        gmt coast -R%coord_gmt% -JM6i -B -Glightgray -Na0.5 -W0.5,black -B+glightblue
        gmt grdimage @earth_gebco_03s -R%coord_gmt% -JM6i -t80
        gmt psxy DISS_gmt/CSSTOP321.gmt -R%coord_gmt% -JM6i -W2,red -t60
        gmt psxy DISS_gmt/CSSPLN321.gmt -R%coord_gmt% -JM6i -W0.1 -G"#FF0000AA" -t85
        gmt text DISS_gmt/Fault_names.txt -R%coord_gmt% -JM6i -F+f12p,Helvetica,red
        gmt plot DISS_gmt/Cities.txt -R%coord_gmt% -JM6i -SS0.3c -Wblack -Gwhite
        gmt text DISS_gmt/Cities.txt -R%coord_gmt% -JM6i -F+f11p,black -D0.4/0.4
        gmt plot %old_earthquakes% -Wfaint -R%coord_gmt% -JM6i -i7,6,8,9+s0.20 -Scc -C%cpt_file%
        gmt plot %coord_section_map_view% -R%coord_gmt% -JM6i -Wblack -Gblack
        gmt plot %coord_section_map_view% -R%coord_gmt% -JM6i -Sc0.2c -Wblack
        gmt plot temp/coord_section_start -JM6i -Sl0.5c+tA -D-0.3/-0.3 -Wblack -Gblack
        gmt plot temp/coord_section_end -JM6i -Sl0.5c+tB -D0.3/0.3 -Wblack -Gblack
        gmt plot %last_earthquake% -Wfaint -R%coord_gmt% -JM6i -i7,6,8,9 -Sa0.80 -Gyellow
        gmt subplot end
    REM Terzo subplot (non proprio): section
    gmt psbasemap -JX23.0c/8.5c -R0/%length_sect%/%depth%/3 -B10g10 -Y1.5
    for /F "delims=" %%x in (%fault_list%) do (
          gmt project DISS_gmt/vertex_sources/%%x -C%start_lon%/%start_lat% -E%end_lon%/%end_lat% -Q -W-0.5/0.5 > temp/projected_DISS
          sort temp/projected_DISS > temp/projected_DISS_
          ren temp/projected_DISS_ temp/projected_DISS
          gmt psxy temp/projected_DISS -JX23.0c/8.5c -R0/%length_sect%/%depth%/3 -i3,2 -W3,red
    )
    echo 0	%depth% > temp/label
    gmt plot temp/label -JX23.0c/8.5c -Sl1c+tA -D0.5/0.5 -Wblack -Gblack
    echo %length_sect%	%depth% > temp/label
    gmt plot temp/label -JX23.0c/8.5c -Sl1c+tB -D-0.5/0.5 -Wblack -Gblack
    REM Parte del terzo plot per avere la topografia sulla sezione
    gmt grdtrack -G@earth_relief_01m -E%start_lon%/%start_lat%/%end_lon%/%end_lat% -N > track
    %py% SATA_m_to_km.py
    del track
    gmt project output3 -C%start_lon%/%start_lat% -E%end_lon%/%end_lat% -Q -W-30/30 -i0,1,3 > proiezione_output
    gmt plot proiezione_output -JX23.0c/8.5c -R0/%length_sect%/%depth%/3 -W1.5p,blue -i3,2
    REM fine del plot con i terremoti, sia l'ultimo che gli altri in sezione
    gmt project %last_earthquake% -C%start_lon%/%start_lat% -E%end_lon%/%end_lat% -Q -W-10/10 -i7,6,10 > temp/proiezione_sez_SATA_last
    gmt project %old_earthquake_nohead% -C%start_lon%/%start_lat% -E%end_lon%/%end_lat% -Q -W-10/10 -i7,6,10 > temp/proiezione_sez_SATA_old
    gmt psxy temp/proiezione_sez_SATA_old -JX23c/8.5c -R0/%length_sect%/%depth%/3 -i3,2 -Sc0.2 -Gpurple -W0.05,black
    gmt psxy temp/proiezione_sez_SATA_last -JX23c/8.5c -R0/%length_sect%/%depth%/3 -i3,2 -Sa0.5 -Gyellow -W0.05,black
    REM Quarto subplot (non proprio): elenco ultimi 10 terremotiz
    gmt pstext temp/table_ten_eqs -R-15/18/0.5/11.5 -JX8.5 -B0 -F+f10p,Helvetica -X23.8
    gmt colorbar -C%cpt_file% -DjCB+w3i/0.1i+o0.5i/0i+h -Bxa20f5 -By+l"Eq. Depth" -X-22 -Y29
    gmt pstext temp/all_data -R0/1/0/1 -JM6i -Bn -F+cTL+f13p -Y-13.7 -X-1 -N
    gmt text DISS_gmt/info -R-3/3/0/3 -JX30c/1 -Bn -F+f11p,Helvetica -Y-17
gmt end show

REM clear temporaneus variables
del py
del cpt_file
del output3
del proiezione_output
