;PROCEDURE: ee_fits_save
;PURPOSE: save relevant information from IRIS FITS files
;PARAMETERS:
;  head=array containing raster image FITS header
;  wrapper_state=which raster image set we are analyzing
;  rasterdir=string of the directory where we will save the data
;VARIABLES:
;  crpix=array of reference pixels along image axes
;  cunit=string array of units for image axes
;  naxis=number of pixels along axis
;  cdelt=conversion value between pixels and a physical unit
;  xcen,ycen=location of the center of the image on the solar disk
;  name=the name of the file to be saved, "obsinfo#.sav"
;PRODUCES: obsinfo#.sav
;AUTHOR(s): A.E. Bartz 6/16/17

pro ee_fits_save, head, wrapper_state, rasterdir
;These values are the same for all of the rasters in our image
  crpix=[head.crpix1,head.crpix2,head.crpix3]
  cunit=[head.cunit1,head.cunit2,head.cunit3]
  naxis=[head.naxis1,head.naxis2,head.naxis3]
  cdelt=[head.cdelt1,head.cdelt2]
  xcen=head.xcen
  ycen=head.ycen

  name=rasterdir+'obsinfo'+strcompress(string(wrapper_state), /remove_all)+'.sav'

  save, crpix, cunit, naxis, cdelt, xcen, ycen, file=name
end
