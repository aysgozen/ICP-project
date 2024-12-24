import Map "mo:base/HashMap";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";

actor {
    type Name = Text;
    type Phone = Text;
    type Entry = {
        desc: Text;
        phone: Phone;
        createTime: Time.Time;
        lastUpdate: Time.Time;
    };
    type Message = {
        receiver: Text;
        mess: Text;
        timestamp: Time.Time;
        isRead: Bool;
    };

    
    let phoneBook = Map.HashMap<Name, Entry>(0, Text.equal, Text.hash);
    let MessageHistory = Map.HashMap<Phone, Message>(0, Text.equal, Text.hash);
    
  
    let userGroups = Map.HashMap<Text, [Name]>(0, Text.equal, Text.hash);
    let blockedContacts = Map.HashMap<Phone, [Phone]>(0, Text.equal, Text.hash);

    
    public func insert(name: Name, entry: Entry): async () {
        let newEntry = {
            desc = entry.desc;
            phone = entry.phone;
            createTime = Time.now();
            lastUpdate = Time.now();
        };
        phoneBook.put(name, newEntry);
    };
    
    public query func getPhone(name: Name): async ?Entry {
        phoneBook.get(name)
    };

    public func sendMessage(senderPhone: Phone, message: Message): async () {
        let newMessage = {
            receiver = message.receiver;
            mess = message.mess;
            timestamp = Time.now();
            isRead = false;
        };
        MessageHistory.put(senderPhone, newMessage);
    };

    public query func sendMessages(senderPhone: Phone): async ?Message {
        MessageHistory.get(senderPhone)
    };

    // Yeni eklenen fonksiyonlar
    public func updateEntry(name: Name, newDesc: Text): async Bool {
        switch (phoneBook.get(name)) {
            case null return false;
            case (?entry) {
                let updatedEntry = {
                    desc = newDesc;
                    phone = entry.phone;
                    createTime = entry.createTime;
                    lastUpdate = Time.now();
                };
                phoneBook.put(name, updatedEntry);
                return true;
            };
        };
    };

    public func createGroup(groupName: Text, members: [Name]): async () {
        userGroups.put(groupName, members);
    };

    public func blockContact(userPhone: Phone, blockedPhone: Phone): async () {
        switch (blockedContacts.get(userPhone)) {
            case null {
                blockedContacts.put(userPhone, [blockedPhone]);
            };
            case (?existing) {
                let newBlocked = Array.append(existing, [blockedPhone]);
                blockedContacts.put(userPhone, newBlocked);
            };
        };
    };

    public query func isBlocked(userPhone: Phone, contactPhone: Phone): async Bool {
        switch (blockedContacts.get(userPhone)) {
            case null return false;
            case (?blocked) {
                for (phone in blocked.vals()) {
                    if (phone == contactPhone) return true;
                };
                return false;
            };
        };
    };

    public query func getMessageStatus(messageId: Phone): async ?Bool {
        switch (MessageHistory.get(messageId)) {
            case null return null;
            case (?message) return ?message.isRead;
        };
    };

    public func markMessageAsRead(messageId: Phone): async Bool {
        switch (MessageHistory.get(messageId)) {
            case null return false;
            case (?message) {
                let updatedMessage = {
                    receiver = message.receiver;
                    mess = message.mess;
                    timestamp = message.timestamp;
                    isRead = true;
                };
                MessageHistory.put(messageId, updatedMessage);
                return true;
            };
        };
    };
};
