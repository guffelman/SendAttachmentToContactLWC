public with sharing class SendAttachmentToContactController {
  @AuraEnabled(cacheable = true)
  public static List < ContentDocument > getAttachmentsForRecord(String recordId) {
    // Query the ContentDocumentLink object to get related ContentDocumentIds
    List < ContentDocumentLink > documentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId];

    // Initialize a set to store the ContentDocumentIds
    Set < Id > documentIds = new Set < Id > ();

    // Populate the set with ContentDocumentIds
    for (ContentDocumentLink link: documentLinks) {
      documentIds.add(link.ContentDocumentId);
    }

    // Query ContentDocument to retrieve attachments
    List < ContentDocument > attachments = [SELECT Id, Title, FileExtension FROM ContentDocument WHERE Id IN: documentIds];

    return attachments;
  }

  @AuraEnabled
public static void sendEmailWithAttachment(String[] contactIds, String selectedAttachmentId, String recordId) {
  // Query for contacts using the contactIds
  List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE Id IN :contactIds];

  List<String> contactEmails = new List<String>();
  for (Contact c : contacts) {
      contactEmails.add(c.Email);
  }
  System.debug('DEBUG: Contact Email Addresses: ' + String.join(contactEmails, ';'));


  // Create a SingleEmailMessage
  Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

  // Set email addresses and other attributes
  email.setToAddresses(contactEmails);
  email.setSubject('Contact Email w/ Attachment');
  email.setPlainTextBody('Test body. See attachment.');

  // Determine the file extension
  String fileExtension = getFileExtension(selectedAttachmentId);

  // Attach the file from the email to the email message as an attachment
  Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
  efa.setFileName(getAttachmentFileName(selectedAttachmentId, fileExtension));
  efa.setBody(base64AttachmentBody(selectedAttachmentId));

  // Attach the file to the email message
  email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

  // Send the email
  Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

  // Log the email on the activity feed of the related record
  if (results[0].isSuccess()) {
      EmailMessage emailMsg = new EmailMessage();
      emailMsg.Subject = email.getSubject();
      emailMsg.TextBody = email.getPlainTextBody();
      emailMsg.HtmlBody = email.getHtmlBody();
      emailMsg.FromAddress = UserInfo.getUserEmail();
      emailMsg.ToAddress = String.join(email.getToAddresses(), ';');
      emailMsg.RelatedToId = recordId;
      emailMsg.Status = '2'; // '2' represents 'Completed' status
      insert emailMsg;

      // Create an Attachment and relate it to the EmailMessage
      Attachment attachment = new Attachment();
      attachment.ParentId = emailMsg.Id; // EmailMessage record's Id
      attachment.Name = getAttachmentFileName(selectedAttachmentId, fileExtension);
      attachment.Body = base64AttachmentBody(selectedAttachmentId);
      insert attachment;
  } else {
      System.debug('Email sending failed: ' + results[0].getErrors()[0].getMessage());
  }
}

@AuraEnabled
public static String getAttachmentUrl(String contentDocumentId) {
    ContentVersion cv;
    try {
        cv = [SELECT Id, Title, FileExtension FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId LIMIT 1];
    } catch (Exception e) {
        // Handle the exception appropriately, e.g., log an error or return a default URL
        return 'Error: Unable to retrieve attachment URL';
    }

    // Construct the attachment URL using the instance URL
    String instanceUrl = URL.getCurrentRequestUrl().toExternalForm().substringBefore('/s/');
    String attachmentUrl = instanceUrl + '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL&versionId=' + cv.Id;

    return attachmentUrl;
}


  private static String getAttachmentFileName(String contentDocumentId, String fileExtension) {
    ContentVersion cv = [SELECT Title FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId LIMIT 1];
    String fileName = cv.Title;
    return fileName + '.' + fileExtension;
  }
  // Helper method to retrieve attachment body
  private static Blob base64AttachmentBody(String contentDocumentId) {
    ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId LIMIT 1];
    return cv.VersionData;
  }

  private static String getFileExtension(String contentDocumentId) {
    ContentVersion cv = [SELECT FileExtension FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId LIMIT 1];
    return cv.FileExtension;
  }

}