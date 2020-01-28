<img src="https://github.com/farique1/consolidate-data/blob/master/Images/GitHub_AMCD_Logo-02.png" alt="Attract Mode Consolidate Data" width="290" height="130">  

# Attract Mode Consolidate Data

## What it is.  

**Consolidate Data** will find, combine and display all occurrences of years, publishers(manufacturers) and categories(genres) on your **Attract Mode** romlists, showing which systems and games are using them. It will also allow you to change and standardize the data across the emulators and games.  

## How to use.  

>**CSD** need to be on the same folder as its `Data` and `ListsBackup` subfolders.  

![#gui](https://github.com/farique1/consolidate-data/blob/master/Images/gui.png)

From top to bottom, main interface:  

- *System selection box:*  
Select which system to view. The changes you made will only affect the system being listed.
If "All Systems" is selected, all systems will be searched/changed.  

- *Data type selection box:*  
The type of data to show and edit. Currently: years, publishers(manufacturers) and categories(genres)  

- *Items:*  
The number of items on the current list.  

- *The List:*  
The list with the data type and systems selected. The numbers on the right are the number of games using this data type. When more than one system has the same data, the systems will be shown separately, each with its respective amounts. When viewing "Show Sums", the quantity will be a sum of the games using the same data across all systems.  

- *Search box:*  
Refines the search on the current list. Press enter to apply. Erase the box and press enter to show the whole list again.  

- *Erase search (X):*  
Erase the search box and show the complete list.  

- *Total:*  
Show the sum of all occurrences on the list.  

- ***AM** Path button:*  
Points to the **Attract Mode** installation folder. After selecting the correct path, **CSD** will automatically start the scan. Hover over it to see the current path. **CSD** will get its data from the romlists `.txt` on the "romlists" **Attract Mode** folder.  

- *Rescan button:*  
Performs a new scan of the data on the current path.  

- *No Quantity check box:*  
Allows a faster scan, WITHOUT calculating the quantities.  

- *Show Sums button:*  
Sums the same data across the systems, showing the total on the list. You cannot edit an entry on this mode.  

- *Show Games button:*  
Show all the games using the selected data on all the systems on the current list. **CSD** will show the rom name, the game title and the system it belongs to.  

- *Change button:*  
Opens a requester that allows you to change the currently selected data. More on this later  

- *Copy button:*  
Copy the current list to the clipboard.  

- *Export Button:*  
Saves the current list.  

- *Backup Lists button:*  
Make a copy of the **Attract Mode** romlists to a local folder (`ListsBackup`)  

- *Help button:*  
Show this.  


## The Change requester (use with caution)  

The change requester allows you to change the data, one at a time, helping to standardize the romlists information from within **CSD**. Please backup the romlists before using this.

- *The change from box:*  
On the first box is the data to search for and change, it can be selected from the pull-down list or entered by hand. If there was a row selected when entering this dialog, the data will be shown here.  

- *The change to box:*  
The second box is the data to replace with. Again, this can be selected from the pull-down list or entered by hand.  

The labels will show the type of data and the systems affected.  

After the change is made, the requester will be closed and the list on the main interface will be refreshed to reflect the changes.  

>To allow the possibility of making a lot of changes faster there are two experimental features (not tested enough and a little dangerous) to help.  
USE THEM WITH CAUTION:  
  > - *Do not close this dialog check box:*  
Will keep the change dialog opened. The lists will not be refreshed and the information on the drop boxes will be out of date which may cause problems.  
>  
> - *Do not refresh afterwards check box:*  
Will close the dialog but will not refresh the lists. Will speed things a bit but can lead to the same problems when searching and replacing information.  
>  
> - *Do not show warnings check box:*  
I did the warnings for myself, so you should keep them too, but, should you choose to ignore them, check this box. Just remember: Warnings are good. Warnings are safe.  

## Acknowledgements


Enjoy and send feedback.  
Thanks.  

***CSD** is offered as is with no guaranties whatsoever. We (I) will not be responsible for any harm it decides to do to your romlists, assets, Attract Mode, operating system, computer or life. I think, though, it will behave (mostly)*  
