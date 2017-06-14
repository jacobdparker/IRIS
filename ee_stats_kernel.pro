;KERNEL
;PURPOSE: Perform variety of statistical functions on EE data  based
;on user input
;VARIABLES:
;  files=array of filepaths of ee.sav files
;  arr=array of x0,x1,y0,y1 data for each of ee.sav files
;  counts=array of number of boxes drawn in each ee.sav file
;  dates=array of julian dates of each ee.sav observation
;  i,j=counting variables
;  input,char=character input read from terminal
;FIND DESCRIPTIONS OF OUTSOURCED FUNCTIONS IN THEIR INDIVIDUAL FILES
;AUTHOR(S): A.E.Bartz 6/9/17


print, "Initializing data..."
if ISA(files) then print, 'Files exist; continuing' else begin
   print, 'Finding data files...'
   files=file_search("../EE_Data","ee_*.sav")
endelse

if ISA(dates) then print, 'Event dates found; continuing' else begin
   print, 'Finding event dates...'
   dates=ee_pathdates(files)
endelse

if ISA(arr) then print, 'Data boxes assigned; continuing' else begin
   print, 'Assigning data boxes...'
   arr=ee_box_data(files)
endelse
   
if ISA(counts) then print, 'Event counts assigned; continuing' else begin
   print, 'Assigning event counts...'
   counts=ee_event_counts(files)
endelse

i=0
j=0
while i eq 0 do begin
   print, format='(%"\nThis program performs statistical analyses on selected IRIS sit and stare data. \nType one of the letters below to perform its corresponding analysis.")'
   print, format='(%"t - time statistics\ny - position statistics\nc - overall statistics\nw - gimme a second\nq - quit the program")'
   input=''
   wait, 1
   READ, input, PROMPT='Type an option here: '

   case input of
      't': begin
         ee_timestats, arr, dates, counts
         wait, 1
         STOP, "Type .c when you're done with the data."
         break
      end

      'y': begin
         ee_ystats, arr, dates, counts
         wait, 1
         STOP, "Type .c when you're done with the data."
      end

      'c': begin
         ee_overallstats, arr, dates, counts
         wait, 1
         STOP, "Type .c when you're done with the data."
      end
      
      'q': begin
         print, "Exiting the program..."
         wait, 2
         i=1
         j=1
         break
      end

      'w': begin
         STOP, "Ok, giving you a second! Type .c to continue when you're ready."
         j=1
      end
      
      else: begin
         print, "Invalid input."
         wait, 2
      endelse
      
   endcase

       while j eq 0 do begin
          char=''
          read, char, PROMPT='Continue program? (y/n) '
          if (char eq 'y') or (char eq 'yes') then begin
             wait, 1
             break
          endif
          if (char eq 'n') or (char eq 'no') then begin
             print, "Exiting..."
             i=1
             wait, 2
             break
          endif else begin
             print, "Invalid input."
             wait, 1
             continue
          endelse
       endwhile
           
    endwhile

end
