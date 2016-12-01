;NAME:
;  eemovie
;
;PURPOSE:
;  Ingest an ee.sav file produced by eemouse, and produce a corresponding movie.
;  All our EE identification goes back to the SiIV raster, so the movie frames
;  are generated starting with that data cube. The ith frame of the movie will
;  use the ith layer of the raster.
;
;CALLING SEQUENCE:
;  eemovie, [/mencoder]
;
;INPUT PARAMETERS:
;  n/a
;
;KEYWORDS:
;  mencoder - spawns a sequence of commands to produce a movie from
;             the jpegs using MEncoder
;
;MODIFICATION HISTORY:
;  2014-Jun-16 C. Kankelborg
;  2014-Jun-23 S. Jaeggli, added mencoder keyword, altered scaling


pro eemovie, mencoder=mencoder

  common widget_environment, img, didx, tidx, mouseread
  common eemouse_environment, rasterfile, rasterdir, sjifile, SiIV_EE_map
  

  device, get_decomposed=old_decomposed
  device, decomposed=0


  ;Load an ee.sav file.
  eefile = dialog_pickfile(title='Select ee.sav file', get_path=new_rasterdir) 
  ;rasterdir gets redefine here.
  restore, eefile


  ;See if the directory has changed since last time.
  if new_rasterdir ne rasterdir then begin
     rasterdir = new_rasterdir

     foo = dialog_message("Don't Panic. Apparently the directory name has changed since ee.sav was last saved. Please identify the corresponding raster and sji files. They must live in the same directory as ee.sav.",/information)

     rasterfile = dialog_pickfile(title='Select L2 Raster File', path=rasterdir)
     sjifile = dialog_pickfile(title='Select L2 SJI File', path=rasterdir)
     save, img,didx,tidx,mouseread,rasterfile,rasterdir,sjifile, SiIV_EE_map, file = rasterdir+'ee.sav' 
   ;Note that all the variables & both common blocks are saved, because we 
   ;might need them to /resume later.
     foo=dialog_message('saved '+rasterdir+'ee.sav', /information)
     
  endif


  message,'Reading SJI data...',/information
  read_iris_l2, sjifile, sjiindex, sjidata
  sjidata[where(sjidata eq -200)]=!values.f_nan

  message,'Reading raster data...',/information
  read_iris_l2, rasterfile, rasterindex, rasterdata, WAVE= 'Si IV'
  rasterdata[where(rasterdata eq -200)]=!values.f_nan

  message,'Subtracting raster background...',/information
  dark_model = fuv_bg_model(rasterdata, percentile=35, $
                            bad_data=!values.f_nan) ;background subtraction


  ;Scaling of images for movie (0.1%-99.9% percentile threshold)
  img=sqrt(sjidata)
  good=where(finite(img) eq 1)
  lohi=prank(img[good], [0.1,99.9])
  sjibyte = bytscl(img, lohi[0], lohi[1])

  img=sqrt(rasterdata)
  good=where(finite(img) eq 1)
  lohi=prank(img[good], [0.1,99.9])
  rastbyte = bytscl(img, lohi[0], lohi[1])

  ;redefine box colors
  mouseread.color=round(255.*randomu(seed, n_elements(mouseread.color)))

  ;Work out sizes of things.
  rastsize = size(rasterdata)
  Nlambda = rastsize[1]
  Ny_SiIV = rastsize[2]
  Nt_SiIV = rastsize[3]
  sjisize = size(sjidata)
  Nx = sjisize[1]
  Ny = sjisize[2]
  if Ny ne Ny_SiIV then message, $
     'SJI and raster have differing y-sizes. I give up!'

  ;Timing information from this dataset...
  time_SiIV = anytim(rasterindex.date_obs,/TAI)
  time_sji  = anytim( sjiindex.date_obs,/TAI)

  ;Create movie frames.
  win=1 & pixwin=2
  window, win, xsize=Nlambda+Nx, ysize=Ny, title='Movie Frame'
  window, pixwin, xsize=Nlambda+Nx, ysize=Ny, /pixmap

  set_plot,'x'

  file_mkdir, new_rasterdir+'movie_jpg'

  for i=0, Nt_SiIV-1 do begin
     loadct, '0'
     wset, pixwin

     foo = min( abs(time_SiIV[i] - time_sji), j ) ;identify nearest-in-time SJI.
     tv, [ rastbyte[*,*,i], sjibyte[*,*,j] ] ;ith movie frame uses jth SJI.
     xyouts, 2, 2, rasterindex[i].date_obs, charsize=2, /device ;annotate frame with time.

     good=where(i gt mouseread.x0 and i lt mouseread.x1, boxcount)

     if boxcount ne 0 then begin
        loadct, '25'

        for b=0,boxcount-1 do begin

           ;plot boxes on spectrum
           y=(mouseread.y1[good[b]]+mouseread.y0[good[b]])/2.
           x=(rasterindex[i].wavelnth - rasterindex[i].wavemin) / $
             rasterindex[i].cdelt1
           width=[100,mouseread.y1[good[b]]-mouseread.y0[good[b]]]
           tvbox, width, x, y, /device, color=mouseread.color[good[b]]
           xyouts, x+width[0]/2., y, string(good[b], format='(I4)'), /device, $
                   color=mouseread.color[good[b]]

           ;plot boxes on sji image
           y=(mouseread.y1[good[b]]+mouseread.y0[good[b]])/2.
           x=sjiindex[j].sltpx1ix+nlambda
           width=(mouseread.y1[good[b]]-mouseread.y0[good[b]])*[1.,1.]
           tvbox, width, x, y, /device, color=mouseread.color[good[b]]
           xyouts, x+width[0]/2., y, string(good[b], format='(I4)'), /device, $
                   color=mouseread.color[good[b]]
        endfor
     endif

     ;Save movie frame.
     write_jpeg, new_rasterdir+'movie_jpg/'+string(i,format='(i05)')+'.jpg', $
                 tvrd(/true), quality=100, /true

     ;Display movie frame
     wset, win
     device, copy=[0,0,nlambda+nx,ny,0,0,pixwin]
  endfor

  if keyword_set(mencoder) eq 1 then begin
     spawn, 'mencoder "mf://'+new_rasterdir+ $
            'movie_jpg/*.jpg" -mf fps=30, -o '+new_rasterdir+ $
            'movie.avi -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=10000:vpass=1'
     spawn, 'mencoder "mf://'+new_rasterdir+ $
            'movie_jpg/*.jpg" -mf fps=30, -o '+new_rasterdir+ $
            'movie.avi -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=10000:vpass=2'
  endif

  device, decomposed=old_decomposed

end
