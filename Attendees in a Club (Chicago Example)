Select distinct

---- Select ID Number
EP_Participant.Id_Number,

---- Select Event ID Number
EP_Event.Event_Id,

--- Select Names

Entity.Last_Name,
Entity.First_Name,
Entity.Record_Type_Code,

---- Select Event Name, Event Status, Event Start Date, Event Stop Date, Organizer Code
EP_Event.Event_Name,
EP_Event.Event_Status_Code,
EP_Event.Event_Start_Datetime,
EP_Event.Event_Stop_Datetime,
EP_Event_Organizer.Organization_Id,
rpt_pbh634.v_nu_events.event_organizers

--- Using Event as Main Table
From EP_Event

--- Joining Participants, Registration, Organizer, Event Codes and Entity Table to Event Table

Left Join EP_Participant ON EP_Event.Event_Id = Ep_Participant.Event_Id
Left Join ep_registration On ep_registration.event_id = EP_Event.Event_Id
Left Join EP_Event_Organizer On EP_Event_Organizer.Event_Id = EP_Event.Event_Id
Left Join EP_Event_Codes On EP_Event_Codes.Event_Id = EP_Event.Event_Id
Left Join Entity On Entity.Id_Number = EP_Participant.Id_Number
Left Join rpt_pbh634.v_nu_events ON rpt_pbh634.v_nu_events.event_id = EP_Event.Event_Id

--- Searched for FY 19 Turnout (Ask Paul for prior years and how to create a column to distingish FY)
Where EP_Event.Event_Start_Datetime >= To_Date ('09/01/2015','mm/dd/yyyy')

--- Registration Status = 2 (Registrations)
And ep_registration.registration_status_code = '2'

--- Pulling KSM School Organizer Code
And EP_Event_Organizer.Organization_Id = '0000646363'

---- Paul's Table (Kellogg Organizer is Yes)

And rpt_pbh634.v_nu_events.kellogg_organizers = 'Y'

--- Removing IDs without a name
And Entity.Id_Number is not null


Order By EP_Event.Event_Id ASC
