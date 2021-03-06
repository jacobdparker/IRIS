;PROCEDURE: ee_discplot
;PURPOSE: plot the location of all events on the solar disk (over time?)
;PARAMETERS:
;  lengths,heights=dimensions of event boxes in respectively hours and
;                  arcsec
;  dates=Julian dates of observations
;  counts=number of boxes drawn per image
;  fitsheads,timefiles=paths to files containing observation and time info
;VARIABLES:
;  depth=number of observations
;  centers=center pixel of each observation
;  fov=field of view of each observation
;  avg_area=the average area of an event box
;  obs,i=counting variables
;PRODUCES: plot with yellow circle representing solar disc
;AUTHOR(S): A.E. Bartz 6/20/17

pro ee_discplot, lengths, heights, dates, counts, fitsheads, timefiles,$
                 avg_len, avg_height

  depth=n_elements(counts)
  centers=fltarr(2,depth)
  fov=fltarr(2,depth)
  
  for obs=0,depth-1 do begin
     restore, fitsheads[obs]
     centers[0,obs]=[xcen,ycen]
     fov[0,obs]=[fovx,fovy]
  endfor

  ;; mn_len=min(avg_len)
  ;; mn_hgt=min(avg_height)
  ;; scale_len=2.0/(max(avg_len)-mn_len)
  ;; scale_hgt=255/(max(avg_height)-mn_hgt)

  ;; d1=plot('sqrt(960^2-x^2)',/WIDGETS,thick=10,'-y',$
  ;;         xrange=[-960,960],yrange=[-960,960],$
  ;;         xtitle="Arcsec",ytitle="Arcsec",aspect_ratio=1,$
  ;;         title="Position, relative size, and relative length of box events")
  ;; d1=plot('-sqrt(960^2-x^2)',/OVERPLOT,thick=10, '-y')
  
  ;; p=plot([centers[0,0]],[centers[1,0]],/OVERPLOT,linestyle=6,$
  ;;        /sym_filled, sym_transparency=50,$
  ;;        symbol='o', sym_size=1.5+(avg_len[0]-mn_len)*scale_len, $
  ;;        sym_color=[0,255,(avg_len[0]-mn_hgt)*scale_hgt])

  ;; for i=1,depth-1 do begin
  ;;    p=plot([centers[0,i]],[centers[1,i]],/WIDGETS,linestyle=6,'o',$
  ;;           /sym_filled, sym_transparency=50, /OVERPLOT,$
  ;;           sym_size=1.5+(avg_len[i]-mn_len)*scale_len,$
  ;;           sym_color=[0,255,(avg_height[i]-mn_hgt)*scale_hgt])
  ;; endfor

  ;; ;ctable=colortable([[0,255,0],[0,255,255]])
  ;; ;c=colorbar(range=[mn_hgt,max(avg_height)],rgb_Table=ctable)

  ;Compute number of observations outside of the limb
  limbx=[findgen(1920,start=-960),findgen(1920,start=960,increment=-1)]
  outside=where((centers[1,*] gt sqrt(960^2-(centers[0,*])^2)) OR $
        (centers[1,*] lt -sqrt(960^2-(centers[0,*])^2)))
  print, "There are "+strcompress(n_elements(outside))+" observations outside of the limb and their indices are:   ", outside
        
  endfor  
  
end
