import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAllObjects from "@salesforce/apex/FieldHistoryTrackingController.getAllObjects";
import saveSelectedObjects from "@salesforce/apex/FieldHistoryTrackingController.saveSelectedObjects";

export default class FieldHistoryTracking extends LightningElement {
  @track isModalOpen = false;
  @track objectOptions = [];
  @track filteredObjects = [];
  @track paginatedObjects = [];
  @track selectedObjects = [];
  @track selectedFields = [];
  @track pageSize = 25;
  @track currentPage = 1;
  @track isNoObjects = false;
  @track successMessage = "";
  @track errorMessage = "";

  pageSizeOptions = [
    { label: "25", value: "25" },
    { label: "50", value: "50" },
    { label: "100", value: "100" }
  ];

  openModal() {
    this.isModalOpen = true;
    this.fetchObjects();
  }

  closeModal() {
    this.isModalOpen = false;
  }

  handleSearch(event) {
    const searchTerm = event.target.value.toLowerCase();
    this.filteredObjects = this.objectOptions.filter(
      (obj) =>
        obj.apiName.toLowerCase().includes(searchTerm) ||
        obj.label.toLowerCase().includes(searchTerm)
    );
    this.paginateObjects();
  }

  fetchObjects() {
    getAllObjects()
      .then((result) => {
        this.objectOptions = result.map((obj) => ({
          apiName: obj.QualifiedApiName,
          label: obj.Label,
          idPrefix: obj.KeyPrefix,
          objectType: obj.QualifiedApiName.endsWith("__c")
            ? "Custom"
            : "Standard"
        }));
        this.filteredObjects = this.objectOptions;
        console.log("Fetched Objects: ", this.objectOptions);
        this.paginateObjects();
      })
      .catch((error) => {
        console.error("Error fetching objects: ", error);
        this.showToast("Error", "Failed to fetch objects.", "error");
      });
  }

  paginateObjects() {
    const start = (this.currentPage - 1) * this.pageSize;
    const end = start + this.pageSize;
    this.paginatedObjects = this.filteredObjects.slice(start, end);
    this.isNoObjects = this.paginatedObjects.length === 0;
  }

  handlePageSizeChange(event) {
    this.pageSize = event.detail.value;
    this.currentPage = 1;
    this.paginateObjects();
  }

  handlePreviousPage() {
    if (this.currentPage > 1) {
      this.currentPage -= 1;
      this.paginateObjects();
    }
  }

  handleNextPage() {
    if (this.currentPage * this.pageSize < this.filteredObjects.length) {
      this.currentPage += 1;
      this.paginateObjects();
    }
  }

  handleCheckboxChange(event) {
    const isChecked = event.target.checked;
    const apiName = event.target.value;

    if (isChecked) {
      if (!this.selectedObjects.includes(apiName)) {
        this.selectedObjects.push(apiName);
      }
    } else {
      this.selectedObjects = this.selectedObjects.filter(
        (obj) => obj !== apiName
      );
    }

    console.log("Updated selectedObjects:", this.selectedObjects);
  }

  handleSave() {
    console.log("Save button clicked");
    console.log("Selected Objects:", this.selectedObjects);

    if (this.selectedObjects.length > 0) {
      saveSelectedObjects({ objectApiNames: this.selectedObjects })
        .then(() => {
          this.showToast(
            "Success",
            "Selected objects saved successfully.",
            "success"
          );
          this.closeModal();
        })
        .catch((error) => {
          console.error("Error saving selected objects:", error);
          this.showToast(
            "Error",
            error.body.message || "Failed to save selected objects.",
            "error"
          );
        });
    } else {
      this.showToast("Warning", "No objects selected.", "warning");
    }
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }
}
