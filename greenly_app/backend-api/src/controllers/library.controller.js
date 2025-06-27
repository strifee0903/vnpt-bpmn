const JSend = require("../jsend");
const service = require("../services/library.service");

const postContent = async (req, res) => {
  const { library_name, description, process_id, category_id } = req.body;
  const file = req.file ?? null;

  console.log("Received content:", { library_name, description });

  if (!library_name || !description) {
    return res
      .status(400)
      .json(JSend.error("Missing required fields: name, text"));
  }

  const content = {
    library_name: library_name || "Temporary Library Name",
    description: description || "Temporary Description",
    file: `public/files/${file.filename}` ? file.path : null,
    process_id: process_id || null,
    category_id: category_id || null,
  };

  try {
    const result = await service.createContent(content);
    console.log("Content created successfully:", result);

    return res.json(JSend.success(result));
  } catch (error) {
    console.error("Error creating content:", error);
    // console.error("Failed to create content", error);
    return res
      .status(500)
      .json(JSend.error("Internal Server Errorrrrrrrrrrrrrrrr"));
  }
};

const getContentById = async (req, res) => {
  const { id } = req.params;

  try {
    const content = await service.getContentById(id);
    return res.json(JSend.success(content));
  } catch (error) {
    console.error("Error fetching content by ID:", error);
    return res.status(500).json(JSend.error("Failed to fetch content by ID"));
  }
};

const getAllContent = async (req, res) => {
  try {
    const content = await service.getAllContent();
    return res.json(JSend.success(content));
  } catch (error) {
    console.error("Error fetching all content:", error);
    return res.status(500).json(JSend.error("Failed to fetch all content"));
  }
};

const updateContent = async (req, res) => {
  const { id } = req.params;
  const { library_name, description, process_id, category_id } = req.body;
  const file = req.file;

  try {
    const updateData = {
      library_name,
      description,
      process_id: process_id || null,
      category_id: category_id || null,
    };

    if (file) {
      updateData.file = `public/files/${file.filename}`;
    }

    const updatedContent = await service.updateContent(id, updateData);
    return res.json(JSend.success(updatedContent));
  } catch (error) {
    console.error("Failed to update content", error);
    return res.status(500).json(JSend.error("Internal Server Error"));
  }
};

const deleteContent = async (req, res) => {
  const { id } = req.params;

  try {
    await service.deleteDocument(id);
    return res.json(JSend.success({ message: "Content deleted successfully" }));
  } catch (error) {
    console.error("Failed to delete content", error);
    return res.status(500).json(JSend.error("Internal Server Error"));
  }
};

module.exports = {
  postContent,
  getAllContent,
  getContentById,
  updateContent,
  deleteContent,
};
