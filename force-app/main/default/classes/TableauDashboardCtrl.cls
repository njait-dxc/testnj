/**
 * @author
 * @date
 * @description Controller for Tableau Dashboard component
 */

public with sharing class TableauDashboardCtrl
{
	static Map<SObjectType, Map<String, SObjectField>> vObjFieldsMap;

	/**
	* @description Method which is called from TableauDashboard lightning component to replace merge fields in options with the actual field value from record.
	* @param recordId ID of the record being fetched
	* @param optionsJSON
	* @return String
	*/

	@AuraEnabled
	public static String getObjectData(String recordId, String optionsJSON)
	{
		Pattern regexPattern = Pattern.compile('(\\{\\{.*?\\}\\})');
		Matcher regexMatcher = regexPattern.matcher(optionsJSON);
		List<String> mergeFields = new List<String>();
		List<String> fieldNames = new List<String>();
		while (regexMatcher.find())
		{
			mergeFields.add(regexMatcher.group());
		}

		if (!mergeFields.isEmpty())
		{
			SObjectType vObjType = ((Id) recordId).getSobjectType();
			Schema.DescribeSObjectResult vObjDesc = vObjType.getDescribe();
			vObjFieldsMap = new Map<SObjectType, Map<String, SObjectField>>
			{
					vObjType => vObjDesc.fields.getMap()
			};
			String query = 'SELECT ';
			for (Integer index = 0; index < mergeFields.size(); index++)
			{
				String fieldValue = mergeFields[index].replace('{{', '').replace('}}', '');
				if (checkField(vObjType, fieldValue))
				{
					fieldNames.add(fieldValue);
					if (index == mergeFields.size() - 1)
					{
						query += fieldValue;
					}
					else
					{
						query += fieldValue + ',';
					}
				}
			}

			query += ' FROM ' + vObjDesc.getName() + ' WHERE Id = :recordId';
			SObject record = Database.query(query);
			for (Integer index = 0; index < mergeFields.size(); index++)
			{
				String fieldName = fieldNames[index];
				String fieldValue = getFieldValue(record, fieldName);
				if (String.isNotBlank(fieldValue))
				{
					optionsJSON = optionsJSON.replace(mergeFields[index], fieldValue);
				}
			}
		}
		return optionsJSON;
	}

	/**
	* @description Code which checks for related field name and then iterate over fields to get field value from related object.
	* @param record
	* @param fieldName
	* @return String
	*/
	private static String getFieldValue(SObject record, String fieldName)
	{
		while (fieldName.contains('.'))
		{
			String sObjectName = fieldName.substringBefore('.');
			record = record.getSObject(sObjectName);
			fieldName = fieldName.substringAfter('.');
		}

		return String.valueOf(record.get(fieldName));
	}

	/**
	 * @description Checks that field exists on a given object
	* @param pObjType
	* @param pFieldPath
	* @return Boolean
	 */

	private static Boolean checkField(SObjectType pObjType, String pFieldPath)
	{
		if (pObjType == null || pFieldPath == null)
		{
			return false;
		}
		if (!vObjFieldsMap.containsKey(pObjType))
		{
			vObjFieldsMap.put(pObjType, pObjType.getDescribe().fields.getMap());
		}
		if (!pFieldPath.contains('.'))
		{
			return vObjFieldsMap.get(pObjType).containsKey(pFieldPath);
		}
		else
		{
			String vRelationName = pFieldPath.substringBefore('.');
			SObjectField vRelField = vObjFieldsMap.get(pObjType).get(vRelationName.endsWith('__r') ? vRelationName.replace('__r', '__c') : vRelationName + 'Id');
			if (vRelField == null)
			{
				return false;
			}
			else
			{
				return checkField(vRelField.getDescribe().getReferenceTo()[0], pFieldPath.substringAfter('.'));
			}
		}
	}
}